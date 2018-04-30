local tostring, tonumber, select, type, getmetatable, setmetatable, rawget = tostring, tonumber, select, type, getmetatable, setmetatable, rawget
local Types = require('types')
local Any, Array = Types.Any, Types.Array
local OMeta = require('ometa')
local utils = require('utils')
local asc = require('abstractsyntax_commons')
local Literal, NilLiteral, BooleanLiteral, NumberLiteral, IntegerLiteral, RealLiteral, StringLiteral, Name, Keyword, Special, Node, Statement, Expression, Control, Iterative, Invocation = asc.Literal, asc.NilLiteral, asc.BooleanLiteral, asc.NumberLiteral, asc.IntegerLiteral, asc.RealLiteral, asc.StringLiteral, asc.Name, asc.Keyword, asc.Special, asc.Node, asc.Statement, asc.Expression, asc.Control, asc.Iterative, asc.Invocation
local omas = require('ometa_abstractsyntax')
local Binding, Application, Choice, Sequence, Lookahead, Exactly, Token, Subsequence, NotPredicate, AndPredicate, Optional, Many, Consumed, Loop, Anything, HostNode, HostPredicate, HostStatement, HostExpression, RuleApplication, Object, Property, Rule, RuleExpression, RuleStatement = omas.Binding, omas.Application, omas.Choice, omas.Sequence, omas.Lookahead, omas.Exactly, omas.Token, omas.Subsequence, omas.NotPredicate, omas.AndPredicate, omas.Optional, omas.Many, omas.Consumed, omas.Loop, omas.Anything, omas.HostNode, omas.HostPredicate, omas.HostStatement, omas.HostExpression, omas.RuleApplication, omas.Object, omas.Property, omas.Rule, omas.RuleExpression, omas.RuleStatement
local Commons = require('grammar_commons')
local OMetaGrammar = OMeta.Grammar({_grammarName = 'OMetaGrammar', choiceDef = OMeta.Rule({behavior = function (input)
local __pass__, nodes
return input:applyWithArgs(input.grammar.choice, function (input)
__pass__, nodes = input:applyWithArgs(input.grammar.list, input.grammar.sequenceDef, function (input)
return input:applyWithArgs(input.grammar.token, "|")
end, 1)
if not (__pass__) then
return false
end
return true, Choice({nodes = nodes})
end)
end, arity = 0, grammar = nil, name = 'choiceDef'}), sequenceDef = OMeta.Rule({behavior = function (input)
local __pass__, nodes
return input:applyWithArgs(input.grammar.choice, function (input)
__pass__, nodes = input:applyWithArgs(input.grammar.many, input.grammar.node, 1)
if not (__pass__) then
return false
end
return true, Sequence({nodes = nodes})
end)
end, arity = 0, grammar = nil, name = 'sequenceDef'}), node = OMeta.Rule({behavior = function (input)
local __pass__
return input:applyWithArgs(input.grammar.choice, function (input)
local __pass__, name, exp
__pass__, name = input:apply(input.grammar.name)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, ":")) then
return false
end
__pass__, exp = input:apply(input.grammar.prefixexp)
if not (__pass__) then
return false
end
return true, Binding({expression = exp, name = name})
end, function (input)
local __pass__, name, exp
__pass__, name = input:applyWithArgs(input.grammar.token, "^")
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, ":")) then
return false
end
__pass__, exp = input:apply(input.grammar.prefixexp)
if not (__pass__) then
return false
end
return true, Binding({expression = exp, name = name})
end, input.grammar.prefixexp)
end, arity = 0, grammar = nil, name = 'node'}), prefixexp = OMeta.Rule({behavior = function (input)
local __pass__
return input:applyWithArgs(input.grammar.choice, function (input)
local __pass__, exp
if not (input:applyWithArgs(input.grammar.token, "~")) then
return false
end
__pass__, exp = input:apply(input.grammar.suffixexp)
if not (__pass__) then
return false
end
return true, NotPredicate({expression = exp})
end, function (input)
local __pass__, exp
if not (input:applyWithArgs(input.grammar.token, "&")) then
return false
end
__pass__, exp = input:apply(input.grammar.suffixexp)
if not (__pass__) then
return false
end
return true, AndPredicate({expression = exp})
end, input.grammar.suffixexp)
end, arity = 0, grammar = nil, name = 'prefixexp'}), suffixexp = OMeta.Rule({behavior = function (input)
local __pass__
return input:applyWithArgs(input.grammar.choice, function (input)
local __pass__, num, exp
__pass__, exp = input:apply(input.grammar.primexp)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, "/")) then
return false
end
__pass__, num = input:applyWithArgs(input.grammar.choice, input.grammar.intlit, input.grammar.primexp)
if not (__pass__) then
return false
end
return true, Loop({expression = exp, times = num})
end, function (input)
local __pass__, min, exp
__pass__, exp = input:apply(input.grammar.primexp)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, "**")) then
return false
end
__pass__, min = input:apply(input.grammar.intlit)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.optional, function (input)
return input:applyWithArgs(input.grammar.choice, function (input)
local __pass__, max
if not (input:applyWithArgs(input.grammar.token, "..")) then
return false
end
__pass__, max = input:apply(input.grammar.intlit)
return __pass__, max
end)
end)) then
return false
end
return true, Many({expression = exp, minimum = min, maximum = max})
end, function (input)
local __pass__, exp
__pass__, exp = input:apply(input.grammar.primexp)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, "*")) then
return false
end
return true, Many({expression = exp})
end, function (input)
local __pass__, exp
__pass__, exp = input:apply(input.grammar.primexp)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, "+")) then
return false
end
return true, Many({expression = exp, minimum = RealLiteral({1})})
end, function (input)
local __pass__, exp
__pass__, exp = input:apply(input.grammar.primexp)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, "?")) then
return false
end
return true, Optional({expression = exp})
end, input.grammar.primexp)
end, arity = 0, grammar = nil, name = 'suffixexp'}), primexp = OMeta.Rule({behavior = function (input)
local __pass__
return input:applyWithArgs(input.grammar.choice, function (input)
local __pass__, exp
if not (input:applyWithArgs(input.grammar.token, "(")) then
return false
end
__pass__, exp = input:apply(input.grammar.choiceDef)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, ")")) then
return false
end
exp.scope = true
return true, exp
end, function (input)
local __pass__, exp
if not (input:applyWithArgs(input.grammar.token, "<")) then
return false
end
__pass__, exp = input:apply(input.grammar.choiceDef)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, ">")) then
return false
end
return true, Consumed({expression = exp})
end, function (input)
local __pass__, props
if not (input:applyWithArgs(input.grammar.token, "{")) then
return false
end
__pass__, props = input:apply(input.grammar.props)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, "}")) then
return false
end
return true, Object({array = props[1], map = props[2]})
end, function (input)
local __pass__, literal
if not (input:applyWithArgs(input.grammar.many, input.grammar.ws)) then
return false
end
__pass__, literal = input:apply(input.grammar.strlitQ)
if not (__pass__) then
return false
end
return true, Token({expression = literal})
end, function (input)
local __pass__, literal
if not (input:applyWithArgs(input.grammar.many, input.grammar.ws)) then
return false
end
__pass__, literal = input:apply(input.grammar.strlitL)
if not (__pass__) then
return false
end
return true, Subsequence({expression = literal})
end, function (input)
local __pass__, literal
if not (input:applyWithArgs(input.grammar.many, input.grammar.ws)) then
return false
end
__pass__, literal = input:applyWithArgs(input.grammar.choice, input.grammar.strlitA, input.grammar.intlit, input.grammar.hexlit, input.grammar.boollit, input.grammar.nillit)
if not (__pass__) then
return false
end
return true, Exactly({expression = literal})
end, function (input)
local __pass__
if not (input:applyWithArgs(input.grammar.token, ".")) then
return false
end
return true, Anything({})
end, function (input)
local __pass__, target, name, args
__pass__, name = input:apply(input.grammar.path)
if not (__pass__) then
return false
end
__pass__, target = input:applyWithArgs(input.grammar.optional, function (input)
return input:applyWithArgs(input.grammar.choice, function (input)
local __pass__
if not (input:applyWithArgs(input.grammar.token, "@")) then
return false
end
return input:apply(input.grammar.path)
end)
end)
if not (__pass__) then
return false
end
__pass__, args = input:applyWithArgs(input.grammar.optional, input.grammar.args)
if not (__pass__) then
return false
end
return true, RuleApplication({name = name, target = target, arguments = args or Array({})})
end)
end, arity = 0, grammar = nil, name = 'primexp'}), path = OMeta.Rule({behavior = function (input)
local __pass__
return input:applyWithArgs(input.grammar.choice, function (input)
return input:applyWithArgs(input.grammar.list, input.grammar.name, '.', 1)
end)
end, arity = 0, grammar = nil, name = 'path'}), args = OMeta.Rule({behavior = function (input)
local __pass__, args
return input:applyWithArgs(input.grammar.choice, function (input)
if not (input:applyWithArgs(input.grammar.exactly, '(')) then
return false
end
__pass__, args = input:applyWithArgs(input.grammar.list, input.grammar.choiceDef, function (input)
return input:applyWithArgs(input.grammar.token, ",")
end)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, ")")) then
return false
end
return true, args
end)
end, arity = 0, grammar = nil, name = 'args'}), props = OMeta.Rule({behavior = function (input)
local __pass__
return input:applyWithArgs(input.grammar.choice, function (input)
local __pass__, array, map
__pass__, array = input:apply(input.grammar.choiceDef)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, ";")) then
return false
end
__pass__, map = input:applyWithArgs(input.grammar.list, input.grammar.prop, function (input)
return input:applyWithArgs(input.grammar.token, ",")
end, 1)
if not (__pass__) then
return false
end
return true, {array, Choice({nodes = Array({Sequence({nodes = map})})})}
end, function (input)
local __pass__, array
__pass__, array = input:apply(input.grammar.choiceDef)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.optional, function (input)
return input:applyWithArgs(input.grammar.token, ";")
end)) then
return false
end
return true, {array, NilLiteral({})}
end, function (input)
local __pass__, map
if not (input:applyWithArgs(input.grammar.optional, function (input)
return input:applyWithArgs(input.grammar.token, ";")
end)) then
return false
end
__pass__, map = input:applyWithArgs(input.grammar.list, input.grammar.prop, function (input)
return input:applyWithArgs(input.grammar.token, ",")
end, 1)
if not (__pass__) then
return false
end
return true, {NilLiteral({}), Choice({nodes = Array({Sequence({nodes = map})})})}
end, function (input)
local __pass__
if not (input:applyWithArgs(input.grammar.optional, function (input)
return input:applyWithArgs(input.grammar.token, ";")
end)) then
return false
end
return true, {NilLiteral({}), NilLiteral({})}
end)
end, arity = 0, grammar = nil, name = 'props'}), prop = OMeta.Rule({behavior = function (input)
local __pass__
return input:applyWithArgs(input.grammar.choice, function (input)
local __pass__, prop, index, exp
__pass__, index = input:apply(input.grammar.name)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, ":=")) then
return false
end
__pass__, exp = input:apply(input.grammar.choiceDef)
if not (__pass__) then
return false
end
__pass__, prop = true, Property({expression = exp, index = StringLiteral({index[1]})})
if not (__pass__) then
return false
end
return true, Binding({expression = prop, name = index})
end, function (input)
local __pass__, exp, index
__pass__, index = input:apply(input.grammar.name)
if not (__pass__) then
return false
end
if not (input:applyWithArgs(input.grammar.token, "=")) then
return false
end
__pass__, exp = input:apply(input.grammar.choiceDef)
if not (__pass__) then
return false
end
return true, Property({expression = exp, index = StringLiteral({index[1]})})
end)
end, arity = 0, grammar = nil, name = 'prop'}), special = OMeta.Rule({behavior = function (input)
local __pass__
return input:applyWithArgs(input.grammar.choice, function (input)
return input:applyWithArgs(input.grammar.subsequence, [[..]])
end, function (input)
return input:applyWithArgs(input.grammar.subsequence, [[**]])
end, function (input)
return input:applyWithArgs(input.grammar.subsequence, [[:=]])
end, function (input)
return input:applyWithArgs(input.grammar.exactly, ':')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '=')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '^')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '(')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, ')')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '|')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '{')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '}')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '<')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '>')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, ',')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '.')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, ';')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '*')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '+')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '?')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '/')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '~')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '&')
end, function (input)
return input:applyWithArgs(input.grammar.exactly, '@')
end)
end, arity = 0, grammar = nil, name = 'special'}), keyword = OMeta.Rule({behavior = function (input)
local __pass__
return input:applyWithArgs(input.grammar.choice, function (input)
return input:applyWithArgs(input.grammar.exactly, '')
end)
end, arity = 0, grammar = nil, name = 'keyword'})})
OMetaGrammar:merge(Commons)
return OMetaGrammar
