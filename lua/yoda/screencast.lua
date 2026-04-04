-- lua/yoda/screencast.lua
-- Toggle screen recording from within Neovim.
--
-- Uses macOS `screencapture -v` to record the full screen, then converts the
-- resulting .mov to an optimised GIF via ffmpeg. Intended for capturing demo
-- footage to attach to READMEs and pull requests.
--
-- Prerequisites (macOS only):
--   brew install ffmpeg
--   Grant your terminal Screen Recording permission in
--   System Settings → Privacy & Security → Screen Recording.

local M = {}

local state = {
  recording = false,
  job_id = nil,
  output_path = nil,
}

--- @return string absolute path for the next .mov file
local function next_output_path()
  -- Expanded lazily (not at module load) so $HOME is resolved at call time
  -- and tests that require this module don't trigger vim.fn side effects.
  local dir = vim.fn.expand("~/recordings")
  return dir .. "/nvim_" .. os.date("%Y%m%d_%H%M%S") .. ".mov"
end

local function convert_to_gif(mov)
  local gif = mov:gsub("%.mov$", ".gif")
  vim.fn.jobstart({
    "ffmpeg",
    "-i",
    mov,
    "-vf",
    "fps=10,scale=1200:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse",
    gif,
  }, {
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify("Screencast saved — " .. gif, vim.log.levels.INFO)
          os.remove(mov)
        else
          vim.notify("ffmpeg conversion failed (exit " .. code .. ") — raw file kept: " .. mov, vim.log.levels.WARN)
        end
      end)
    end,
  })
end

local function start()
  local output_path = next_output_path()
  local output_dir = vim.fn.fnamemodify(output_path, ":h")

  if output_dir == "" then
    vim.notify("[screencast] Could not resolve output directory", vim.log.levels.ERROR)
    return
  end

  vim.fn.mkdir(output_dir, "p")

  -- Wire on_exit on the screencapture job itself so ffmpeg only starts once
  -- screencapture has fully written and closed the .mov file. Starting ffmpeg
  -- immediately after jobstop() would be a race — the process may still be
  -- flushing when ffmpeg opens the file, producing a corrupt or truncated GIF.
  local job_id = vim.fn.jobstart({ "screencapture", "-v", output_path }, {
    on_exit = function(_, _code)
      vim.schedule(function()
        convert_to_gif(output_path)
      end)
    end,
  })

  -- jobstart returns 0 (invalid command) or -1 (not executable) on failure.
  if job_id <= 0 then
    vim.notify("[screencast] Failed to start screencapture (macOS only, check PATH and Screen Recording permission)", vim.log.levels.ERROR)
    return
  end

  state.job_id = job_id
  state.output_path = output_path
  state.recording = true
  vim.notify("Recording started — " .. output_path, vim.log.levels.INFO)
end

local function stop()
  local job_id = state.job_id

  -- Reset state before jobstop so a rapid second toggle doesn't re-enter.
  state.recording = false
  state.job_id = nil
  state.output_path = nil

  -- SIGTERM causes screencapture to flush and exit cleanly. The on_exit
  -- callback registered in start() will then invoke convert_to_gif().
  vim.fn.jobstop(job_id)
end

--- Toggle recording on / off.
function M.toggle()
  if state.recording then
    stop()
  else
    start()
  end
end

--- @return boolean
function M.is_recording()
  return state.recording
end

local _setup_done = false

function M.setup()
  -- screencapture is macOS only.
  if vim.fn.has("mac") == 0 then
    return
  end
  if _setup_done then
    return
  end
  _setup_done = true
  vim.keymap.set("n", "<leader>tv", M.toggle, { desc = "[T]oggle [V]ideo recording" })
end

return M
