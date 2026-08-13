-- A conversation that lives in the code, persisted as a tour.nvim tour.
--
-- Your questions are themselves tour steps, anchored at the code you asked
-- about; codex's answers either land inside the question step ("stay there"),
-- as 1-3 new steps at the places the answer is really about, or both. H/L
-- (tour.nvim's session maps) walk the whole conversation, questions included.
--
--   visual <leader>aa / ae / au   ask about the selection -> opens a new stage
--   r (while the tour plays)      reply to the step you're reading
--   normal <leader>ax             delete the current step
--   normal <leader>ad             cancel a running question / close the float
--
-- While codex works (read-only sandbox, headless) its exploration streams into
-- a float pinned above the question; the codex thread id is stashed in the
-- .tour file so the conversation survives restarts.
--
-- Prototype: tour.nvim is driven entirely from outside (stop/load/start/goto).

local M = {}

----------------------------------------------------------------------
-- Tour file
----------------------------------------------------------------------

local function sess()
  return require 'tour.session'
end

local function tour_path()
  return sess().tour_dir() .. '/conversation-' .. os.date '%Y-%m-%d' .. '.tour'
end

local function read_tour(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if ok and #lines > 0 then
    local decoded_ok, raw = pcall(vim.json.decode, table.concat(lines, '\n'))
    if decoded_ok and type(raw) == 'table' then
      return raw
    end
  end
  return { title = 'Conversation', steps = {} }
end

local function write_tour(path, raw)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  local encoded = vim.json.encode(raw)
  if vim.fn.executable 'jq' == 1 then
    local pretty = vim.fn.system({ 'jq', '.' }, encoded)
    if vim.v.shell_error == 0 then
      encoded = pretty
    end
  end
  vim.fn.writefile(vim.split(encoded, '\n', { trimempty = true }), path)
end

local function conversation_active()
  return sess().active() and sess().current().tour.path == tour_path()
end

--- The session-local reply map, mimicking tour.nvim's own session maps:
--- `r` appears when the conversation tour starts and goes away on stop.
local reply_mapped = false
local function unmap_reply()
  if reply_mapped then
    pcall(vim.keymap.del, 'n', 'r')
    reply_mapped = false
  end
end

local stop_patched = false
local function map_reply()
  if not reply_mapped then
    vim.keymap.set('n', 'r', function()
      M.reply_input()
    end, { desc = 'Reply to this tour step' })
    reply_mapped = true
  end
  if not stop_patched then
    stop_patched = true
    local s = sess()
    local orig_stop = s.stop
    s.stop = function(...)
      unmap_reply()
      return orig_stop(...)
    end
  end
end

local function reload_and_goto(index)
  local path = tour_path()
  if sess().active() then
    sess().stop(true)
  end
  local tour, err = sess().load(path)
  if not tour then
    vim.notify('ask: ' .. (err or 'could not load tour'), vim.log.levels.ERROR)
    return
  end
  sess().start(tour)
  if index and index > 1 and index <= #tour.steps then
    sess().goto_step(index)
  end
  map_reply()
end

----------------------------------------------------------------------
-- Streaming progress float
----------------------------------------------------------------------

local float = nil -- { buf, win, anchor_win, line, cmds = {}, msgs = {} }
local proc = nil

local function short_cmd(cmd)
  cmd = cmd:gsub("^/usr/bin/bash %-lc '?", ''):gsub("'?$", '')
  if #cmd > 70 then
    cmd = cmd:sub(1, 67) .. '…'
  end
  return cmd
end

local function float_render()
  if not float or not vim.api.nvim_buf_is_valid(float.buf) then
    return
  end
  local lines = {}
  for _, cmd in ipairs(float.cmds) do
    lines[#lines + 1] = (cmd.running and '⟳ `' or '✓ `') .. cmd.text .. '`'
  end
  for _, msg in ipairs(float.msgs) do
    if #lines > 0 then
      lines[#lines + 1] = ''
    end
    vim.list_extend(lines, vim.split(msg, '\n'))
  end
  if #lines == 0 then
    lines = { '*waiting for codex…*' }
  end
  vim.bo[float.buf].modifiable = true
  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, lines)
  vim.bo[float.buf].modifiable = false

  local width = math.min(84, vim.o.columns - 8)
  local height = 0
  for _, line in ipairs(lines) do
    height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(line) / width))
  end
  height = math.max(1, math.min(height, 12))

  local config = {
    relative = 'win',
    win = float.anchor_win,
    bufpos = { float.line, 0 },
    anchor = 'SW',
    row = 0,
    col = 0,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' codex · working… ',
    zindex = 40,
  }
  if float.win and vim.api.nvim_win_is_valid(float.win) then
    vim.api.nvim_win_set_config(float.win, config)
  else
    float.win = vim.api.nvim_open_win(float.buf, false, config)
    vim.wo[float.win].wrap = true
    vim.wo[float.win].linebreak = true
    vim.wo[float.win].conceallevel = 3
  end
  vim.api.nvim_win_set_cursor(float.win, { math.max(1, #lines), 0 })
end

local function float_open(anchor_line)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].modifiable = false
  float = {
    buf = buf,
    anchor_win = vim.api.nvim_get_current_win(),
    line = math.max(0, anchor_line - 1),
    cmds = {},
    msgs = {},
  }
  float_render()
end

local function float_close()
  if not float then
    return
  end
  if float.win and vim.api.nvim_win_is_valid(float.win) then
    vim.api.nvim_win_close(float.win, true)
  end
  if vim.api.nvim_buf_is_valid(float.buf) then
    vim.api.nvim_buf_delete(float.buf, { force = true })
  end
  float = nil
end

function M.cancel()
  if proc then
    proc:kill(9)
    proc = nil
  end
  float_close()
end

----------------------------------------------------------------------
-- Codex protocol
----------------------------------------------------------------------

local PREAMBLE = [[
You power a conversation that lives inside my code editor. I read code and ask
questions; the whole dialogue is a code tour whose steps are anchored to exact
lines. My questions are themselves steps, anchored where I asked them — when
you receive a question, its step already exists in the tour.

Every reply must be exactly one fenced json block, nothing else:

```json
{
  "tour_title": "<short evolving title for the whole conversation>",
  "reply": "<optional: markdown rendered directly under my question, at its location>",
  "steps": [
    {
      "file": "<repo-relative path>",
      "line": <1-indexed line number>,
      "text": "<that exact line, copied verbatim from the file — this is the anchor>",
      "title": "<short step title>",
      "description": "<markdown prose>",
      "notes": [{"text": "<verbatim nearby line>", "line": <n>, "note": "<short margin remark>"}]
    }
  ]
}
```

Include at least one of "reply" / "steps":
- Use "reply" alone when the answer is about the code where I asked — the
  conversation stays there, threaded under my question.
- Use "steps" (1-3, prefer 1) when the answer genuinely lives elsewhere: one
  step per place, anchored at the code it explains. I walk to them in order.
- Combine them when it helps: a short "reply" that orients, then steps that
  point away.

Rules:
- "text" must be copied character-for-character from the current file content;
  read the file before quoting it.
- In "reply" and descriptions, link to other code as [label](path/to/file:line)
  — those are jumpable for me. Use `backticks` for identifiers. No headings.
- "notes" are optional margin remarks on nearby lines; use them sparingly.
- Keep prose short and concrete: a paragraph or two.
]]

local function topic_message(ctx)
  return table.concat({
    ('New topic. My question is a new step anchored at %s:%d. I selected lines %d-%d:'):format(
      ctx.file,
      ctx.first,
      ctx.first,
      ctx.last
    ),
    '```' .. (ctx.filetype or ''),
    ctx.code,
    '```',
    '',
    'Question: ' .. ctx.question,
  }, '\n')
end

local function reply_message(ctx)
  return table.concat({
    ('Follow-up, asked while reading the step %q (%s:%d). My question is a new step there.'):format(
      ctx.step_title or '?',
      ctx.file,
      ctx.first
    ),
    '',
    'Question: ' .. ctx.question,
  }, '\n')
end

----------------------------------------------------------------------
-- Answer -> tour
----------------------------------------------------------------------

local function extract_json(text)
  local candidates = {}
  for _, pattern in ipairs { '```json%s*(.-)```', '```%s*({.-})%s*```', '({.*})' } do
    local m = text:match(pattern)
    if m then
      candidates[#candidates + 1] = m
    end
  end
  for _, candidate in ipairs(candidates) do
    local ok, decoded = pcall(vim.json.decode, candidate)
    if ok and type(decoded) == 'table' then
      return decoded
    end
  end
end

local function sanitize_steps(decoded)
  if type(decoded.steps) ~= 'table' then
    return nil
  end
  local out = {}
  for _, s in ipairs(decoded.steps) do
    if type(s) == 'table' and type(s.file) == 'string' and type(s.description) == 'string' then
      local step = {
        file = (s.file:gsub('^%./', '')),
        description = s.description,
        title = type(s.title) == 'string' and s.title or nil,
        text = type(s.text) == 'string' and s.text or nil,
      }
      local line = tonumber(s.line)
      if line and line >= 1 then
        step.line = math.floor(line)
      end
      if type(s.notes) == 'table' then
        local notes = {}
        for _, n in ipairs(s.notes) do
          if type(n) == 'table' and type(n.text) == 'string' and type(n.note) == 'string' then
            notes[#notes + 1] = { text = n.text, note = n.note, line = tonumber(n.line) }
          end
        end
        step.notes = #notes > 0 and notes or nil
      end
      out[#out + 1] = step
      if #out == 3 then
        break
      end
    end
  end
  return #out > 0 and out or nil
end

--- Write the question itself into the tour as a step and jump to it.
local function write_question(ctx)
  local path = tour_path()
  local raw = read_tour(path)
  local qstep = {
    file = ctx.file,
    line = ctx.first,
    text = ctx.anchor_text,
    title = '❯ you',
    role = 'user',
    description = '**' .. ctx.question .. '**',
  }
  if ctx.mode == 'topic' then
    qstep.stage = ctx.question:sub(1, 60)
  end
  local at = #raw.steps
  if ctx.mode == 'reply' and ctx.after then
    at = math.min(ctx.after, #raw.steps)
  end
  table.insert(raw.steps, at + 1, qstep)
  ctx.qi = at + 1
  write_tour(path, raw)
  reload_and_goto(ctx.qi)
end

--- Fold the answer into the tour: reply text under the question step, new
--- steps after it, then land on the right step.
local function apply_answer(ctx, decoded, steps, reply_text)
  local path = tour_path()
  local raw = read_tour(path)
  local qi = math.min(ctx.qi or #raw.steps, #raw.steps)
  local q = raw.steps[qi]

  if reply_text and q then
    q.description = (q.description or '') .. '\n\n' .. reply_text
  end
  if q and ctx.mode == 'topic' and type(decoded.stage) == 'string' and decoded.stage ~= '' then
    q.stage = decoded.stage
  end
  for i, step in ipairs(steps or {}) do
    step.stage = nil
    table.insert(raw.steps, qi + i, step)
  end
  if type(decoded.tour_title) == 'string' and decoded.tour_title ~= '' then
    raw.title = decoded.tour_title
  end
  raw.codexThread = ctx.thread_id or raw.codexThread
  write_tour(path, raw)
  reload_and_goto((reply_text or not steps) and qi or qi + 1)
end

----------------------------------------------------------------------
-- Running codex
----------------------------------------------------------------------

local function codex_args(ctx, prompt)
  local args = { 'codex', 'exec' }
  if ctx.resume_id then
    vim.list_extend(args, { 'resume', ctx.resume_id })
  end
  vim.list_extend(args, { '--json', '--sandbox', 'read-only', '--skip-git-repo-check', prompt })
  return args
end

local run_round -- forward declaration (retries recurse)

local function on_answer(ctx, result)
  local answer = ctx.messages[#ctx.messages]
  local decoded = answer and extract_json(answer)
  local steps = decoded and sanitize_steps(decoded)
  local reply_text = decoded and type(decoded.reply) == 'string' and decoded.reply ~= '' and decoded.reply or nil

  if steps or reply_text then
    float_close()
    apply_answer(ctx, decoded, steps, reply_text)
    return
  end

  if result.code ~= 0 and ctx.resume_id and not ctx.retried_fresh then
    -- Thread likely expired: retry on a fresh thread with the tour as context.
    ctx.resume_id = nil
    ctx.retried_fresh = true
    local tour_json = table.concat(vim.fn.filereadable(tour_path()) == 1 and vim.fn.readfile(tour_path()) or {}, '\n')
    local prompt = PREAMBLE
      .. '\n\nHere is the conversation so far:\n```json\n'
      .. tour_json
      .. '\n```\n\n'
      .. ctx.body
    return run_round(ctx, prompt)
  end

  if not ctx.retried_parse and answer then
    ctx.retried_parse = true
    ctx.resume_id = ctx.thread_id or ctx.resume_id
    return run_round(
      ctx,
      'That reply could not be applied: invalid or missing json block. Reply again with only the corrected json block, following the format exactly.'
    )
  end

  -- Repair, never drop: whatever text we got lands under the question.
  float_close()
  if answer then
    apply_answer(ctx, {}, nil, answer)
  else
    vim.notify('ask: codex failed (exit ' .. result.code .. '): ' .. (result.stderr or ''), vim.log.levels.ERROR)
  end
end

run_round = function(ctx, prompt)
  local pending = ''
  proc = vim.system(codex_args(ctx, prompt), {
    text = true,
    cwd = sess().root(),
    stdout = function(_, data)
      if not data then
        return
      end
      pending = pending .. data
      local lines = vim.split(pending, '\n')
      pending = table.remove(lines)
      vim.schedule(function()
        for _, l in ipairs(lines) do
          local ok, ev = pcall(vim.json.decode, l)
          if ok and float then
            local item = ev.item
            if ev.type == 'thread.started' then
              ctx.thread_id = ctx.thread_id or ev.thread_id
            elseif item and item.type == 'command_execution' then
              if ev.type == 'item.started' then
                float.cmds[#float.cmds + 1] = { id = item.id, text = short_cmd(item.command), running = true }
              else
                for _, cmd in ipairs(float.cmds) do
                  if cmd.id == item.id then
                    cmd.running = false
                  end
                end
              end
            elseif item and item.type == 'agent_message' and ev.type == 'item.completed' then
              ctx.messages[#ctx.messages + 1] = item.text
              if item.text:find('```json', 1, true) or item.text:match '^%s*{' then
                float.msgs = { '✍ *composing…*' }
              else
                float.msgs[#float.msgs + 1] = item.text
              end
            end
            float_render()
          end
        end
      end)
    end,
  }, function(result)
    vim.schedule(function()
      proc = nil
      if float then -- not cancelled
        on_answer(ctx, result)
      end
    end)
  end)
end

----------------------------------------------------------------------
-- Entry points
----------------------------------------------------------------------

local function start_round(ctx, body)
  ctx.messages = {}
  ctx.body = body
  M.cancel()
  write_question(ctx)
  float_open(ctx.first)
  local prompt = ctx.resume_id and body or (PREAMBLE .. '\n\n' .. body)
  run_round(ctx, prompt)
end

function M.ask_topic(question)
  local first = math.min(vim.fn.line 'v', vim.fn.line '.')
  local last = math.max(vim.fn.line 'v', vim.fn.line '.')
  local ctx = {
    mode = 'topic',
    question = question,
    file = vim.fn.expand '%:.',
    filetype = vim.bo.filetype,
    first = first,
    last = last,
    code = table.concat(vim.api.nvim_buf_get_lines(0, first - 1, last, false), '\n'),
    anchor_text = vim.api.nvim_buf_get_lines(0, first - 1, first, false)[1],
    resume_id = read_tour(tour_path()).codexThread,
  }
  vim.cmd 'normal! \27'
  start_round(ctx, topic_message(ctx))
end

function M.reply(question)
  if not conversation_active() then
    return vim.notify('ask: no active conversation tour — select code and <leader>aa to start one', vim.log.levels.WARN)
  end
  local st = sess().current()
  local step = st.tour.steps[st.index]
  local ctx = {
    mode = 'reply',
    question = question,
    file = step.file,
    first = step.line or vim.fn.line '.',
    after = st.index,
    step_title = step.title,
    anchor_text = step.text,
    resume_id = read_tour(tour_path()).codexThread,
  }
  start_round(ctx, reply_message(ctx))
end

--- Small chat input floated at the cursor: <CR> sends, <Esc>/q cancels.
function M.reply_input()
  if not conversation_active() then
    return vim.notify('ask: no active conversation tour — select code and <leader>aa to start one', vim.log.levels.WARN)
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = 'markdown'
  local width = math.min(84, vim.o.columns - 8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = width,
    height = 3,
    style = 'minimal',
    border = 'rounded',
    title = ' reply · <CR> sends ',
    zindex = 50,
  })
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  local function send()
    local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n'))
    vim.cmd 'stopinsert'
    close()
    if text ~= '' then
      M.reply(text)
    end
  end
  vim.keymap.set({ 'n', 'i' }, '<CR>', send, { buffer = buf, nowait = true })
  vim.keymap.set('n', '<Esc>', close, { buffer = buf, nowait = true })
  vim.keymap.set('n', 'q', close, { buffer = buf, nowait = true })
  vim.cmd 'startinsert'
end

function M.delete_step()
  if not conversation_active() then
    return vim.notify('ask: no active conversation tour', vim.log.levels.WARN)
  end
  local index = sess().current().index
  local path = tour_path()
  local raw = read_tour(path)
  local removed = table.remove(raw.steps, index)
  -- Keep the stage alive if we removed its opening step.
  if removed and removed.stage and raw.steps[index] and not raw.steps[index].stage then
    raw.steps[index].stage = removed.stage
  end
  if #raw.steps == 0 then
    sess().stop(true)
    vim.fn.delete(path)
    return
  end
  write_tour(path, raw)
  reload_and_goto(math.min(index, #raw.steps))
end

----------------------------------------------------------------------
-- Keymaps
----------------------------------------------------------------------

local function prompt_then(fn)
  return function()
    vim.ui.input({ prompt = 'Ask codex: ' }, function(question)
      if question and question ~= '' then
        fn(question)
      end
    end)
  end
end

vim.keymap.set('v', '<leader>aa', prompt_then(M.ask_topic), { desc = 'Ask codex about selection (new tour stage)' })
vim.keymap.set('v', '<leader>ae', function()
  M.ask_topic 'Explain what this does and why it might be written this way. Be plain and concise.'
end, { desc = 'Ask codex: explain selection' })
vim.keymap.set('v', '<leader>au', function()
  M.ask_topic 'Where is this used or called from in the repo, and what for?'
end, { desc = 'Ask codex: usages of selection' })
vim.keymap.set('n', '<leader>aa', function()
  M.reply_input()
end, { desc = 'Reply to current tour step' })
vim.keymap.set('n', '<leader>ax', M.delete_step, { desc = 'Delete current tour step' })
vim.keymap.set('n', '<leader>ad', M.cancel, { desc = 'Cancel codex question' })

return M
