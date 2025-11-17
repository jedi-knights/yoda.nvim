-- tests/property/core_string_properties_spec.lua
-- Property-based tests for core/string.lua
-- These tests verify mathematical properties that should ALWAYS hold

local property = require("tests.property_based")
local string_utils = require("yoda-core.string")

describe("core.string (property-based)", function()
  -- Set seed for reproducibility in CI
  before_each(function()
    property.set_seed(42)
  end)

  describe("trim()", function()
    it("is idempotent: trim(trim(x)) = trim(x)", function()
      property.property("trim is idempotent", { runs = 200 }, function()
        local input = property.gen.string(0, 50)()
        local once = string_utils.trim(input)
        local twice = string_utils.trim(once)
        assert.equals(once, twice)
      end)
    end)

    it("never makes string longer", function()
      property.property("trim never increases length", { runs = 200 }, function()
        local input = property.gen.string(0, 50)()
        local output = string_utils.trim(input)
        assert.is_true(#output <= #input, string.format("trim made string longer: %d -> %d", #input, #output))
      end)
    end)

    it("result never starts or ends with whitespace", function()
      property.property("trim removes leading/trailing whitespace", { runs = 200 }, function()
        local input = property.gen.string(1, 50)()
        local output = string_utils.trim(input)

        if #output > 0 then
          local first_char = output:sub(1, 1)
          local last_char = output:sub(-1)

          -- Check first and last chars are not whitespace
          assert.is_false(first_char:match("^%s") ~= nil, "Output starts with whitespace: " .. vim.inspect(output))
          assert.is_false(last_char:match("%s$") ~= nil, "Output ends with whitespace: " .. vim.inspect(output))
        end
      end)
    end)
  end)

  describe("starts_with()", function()
    it("concatenation property: starts_with(prefix .. x, prefix) = true", function()
      property.property("prefix concatenation", { runs = 200 }, function()
        local prefix = property.gen.string(1, 20)()
        local suffix = property.gen.string(0, 20)()
        local str = prefix .. suffix

        assert.is_true(string_utils.starts_with(str, prefix))
      end)
    end)

    it("empty prefix: starts_with(x, '') = true", function()
      property.property("empty prefix always matches", { runs = 100 }, function()
        local str = property.gen.string(0, 50)()
        assert.is_true(string_utils.starts_with(str, ""))
      end)
    end)

    it("transitivity: if a starts_with b and b starts_with c, then a starts_with c", function()
      property.property("transitivity", { runs = 100 }, function()
        local c = property.gen.string(1, 10)()
        local b = c .. property.gen.string(1, 10)()
        local a = b .. property.gen.string(1, 10)()

        if string_utils.starts_with(a, b) and string_utils.starts_with(b, c) then
          assert.is_true(string_utils.starts_with(a, c))
        end
      end)
    end)

    it("longer prefix never matches shorter string", function()
      property.property("prefix length constraint", { runs = 200 }, function()
        local str = property.gen.string(0, 20)()
        local prefix = property.gen.string(#str + 1, #str + 20)()

        assert.is_false(string_utils.starts_with(str, prefix))
      end)
    end)
  end)

  describe("ends_with()", function()
    it("concatenation property: ends_with(x .. suffix, suffix) = true", function()
      property.property("suffix concatenation", { runs = 200 }, function()
        local prefix = property.gen.string(0, 20)()
        local suffix = property.gen.string(1, 20)()
        local str = prefix .. suffix

        assert.is_true(string_utils.ends_with(str, suffix))
      end)
    end)

    it("empty suffix: ends_with(x, '') = true", function()
      property.property("empty suffix always matches", { runs = 100 }, function()
        local str = property.gen.string(0, 50)()
        assert.is_true(string_utils.ends_with(str, ""))
      end)
    end)

    it("symmetry with starts_with for single char", function()
      property.property("single char symmetry", { runs = 200 }, function()
        local char = property.gen.string(1, 1, "abcdefg")()
        local str = char

        assert.equals(string_utils.starts_with(str, char), string_utils.ends_with(str, char))
      end)
    end)
  end)

  describe("split()", function()
    it("join(split(x, d), d) contains original (for simple cases)", function()
      property.property("split/join roundtrip", { runs = 100 }, function()
        -- Use simple delimiter that won't appear in string
        local delimiter = "|"
        local str = property.gen.string(0, 30, "abcdefg ")()

        local parts = string_utils.split(str, delimiter)
        local rejoined = table.concat(parts, delimiter)

        assert.equals(str, rejoined)
      end)
    end)

    it("splitting empty string returns array with empty string", function()
      property.property("empty string split", { runs = 50 }, function()
        local delimiter = property.gen.string(1, 3)()
        local result = string_utils.split("", delimiter)

        assert.equals(1, #result)
        assert.equals("", result[1])
      end)
    end)

    it("result never contains delimiter", function()
      property.property("parts don't contain delimiter", { runs = 100 }, function()
        local delimiter = "|"
        local parts_gen = property.gen.array(property.gen.string(0, 10, "abcdefg"), 1, 5)
        local parts = parts_gen()
        local str = table.concat(parts, delimiter)

        local split_parts = string_utils.split(str, delimiter)

        for _, part in ipairs(split_parts) do
          assert.is_false(part:find(delimiter, 1, true) ~= nil, "Part contains delimiter: " .. part)
        end
      end)
    end)
  end)

  describe("is_blank()", function()
    it("trim(x) = '' implies is_blank(x) = true", function()
      property.property("trim relationship", { runs = 200 }, function()
        local str = property.gen.string(0, 50)()

        if string_utils.trim(str) == "" then
          assert.is_true(string_utils.is_blank(str))
        end
      end)
    end)

    it("is_blank(x) = false implies #trim(x) > 0", function()
      property.property("non-blank means non-empty after trim", { runs = 200 }, function()
        local str = property.gen.string(0, 50)()

        if not string_utils.is_blank(str) then
          assert.is_true(#string_utils.trim(str) > 0)
        end
      end)
    end)

    it("monotonicity: is_blank(x) = true implies is_blank(x .. y) depends only on y", function()
      property.property("whitespace prefix irrelevance", { runs = 100 }, function()
        local whitespace = property.gen.string(1, 10, " \t\n")()
        local str = property.gen.string(0, 20)()

        assert.equals(string_utils.is_blank(whitespace .. str), string_utils.is_blank(str))
      end)
    end)
  end)

  describe("get_extension()", function()
    it("adding extension: get_extension(name .. '.' .. ext) = ext", function()
      property.property("extension extraction", { runs = 200 }, function()
        local name = property.gen.string(1, 20, "abcdefg")()
        local ext = property.gen.string(1, 5, "abcd")()
        local path = name .. "." .. ext

        assert.equals(ext, string_utils.get_extension(path))
      end)
    end)

    it("no dot means no extension", function()
      property.property("no dot = no extension", { runs = 100 }, function()
        local str = property.gen.string(0, 30, "abcdefg")()

        assert.equals("", string_utils.get_extension(str))
      end)
    end)

    it("result never contains dot", function()
      property.property("extension has no dot", { runs = 200 }, function()
        local str = property.gen.string(0, 50)()
        local ext = string_utils.get_extension(str)

        assert.is_false(ext:find("%.") ~= nil, "Extension contains dot: " .. ext)
      end)
    end)
  end)

  -- Advanced: Test combinations of functions
  describe("function composition", function()
    it("trim(trim(x)) = trim(x) (idempotence)", function()
      property.property(
        "double trim equals single trim",
        property.properties.involutory(
          function(x)
            return string_utils.trim(x)
          end,
          property.gen.string(0, 50),
          function(a, b)
            return string_utils.trim(a) == string_utils.trim(b)
          end
        )
      )
    end)
  end)

  -- Statistics: Let's see what our generators produce
  describe("generator statistics", function()
    it("string length distribution", function()
      property.classify("String lengths", property.gen.string(0, 50), function(s)
        if #s == 0 then
          return "empty"
        elseif #s < 10 then
          return "short"
        elseif #s < 30 then
          return "medium"
        else
          return "long"
        end
      end, 1000)
    end)

    it("blank string distribution", function()
      property.classify("Blank strings", property.gen.string(0, 50), function(s)
        return string_utils.is_blank(s) and "blank" or "non-blank"
      end, 1000)
    end)
  end)
end)
