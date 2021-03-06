-module(lejson_test).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").

config_test_() ->
    {setup,
     fun setup_config/0,
     fun cleanup_config/1,
     {inorder, [ {timeout, 120,
                  {"encode", fun() -> test_encode({e,n,c}) end}} |
                [ {timeout, 120,
                  {atom_to_list(Name),
                   fun() -> test_decode(Data) end}} ||
                  {Name,_,_} = Data <- json_strings_should_pass()]]}}.

setup_config() -> ok.
cleanup_config(_) -> ok.

json_strings_should_pass() ->
    [{empty_object, <<"{}">>, #{}},
     {simple_object_string_value,
      <<"{\"V\": \"1\"}">>,
      #{<<"V">> => <<"1">>}},
     {space_tester,
      <<"{  \"v\":\"1\"\r\n}">>,
      #{<<"v">> => <<"1">>}},
     {simple_object_int_value,
      <<"{\"V\": 1}">>,
      #{<<"V">> => 1}},
     {simple_object_quote_in_string,
      <<"{ \"v\":\"ab'c\"}">>,
      #{<<"v">> => <<"ab'c">>}},
     {simple_object_float_value,
      <<"{ \"PI\":3.141E-10}">>,
      #{<<"PI">> => 3.141e-10}},
     {lower_case_float_value,
      <<"{ \"PI\":3.141e-10}">>,
      #{<<"PI">> => 3.141e-10}},
     {long_number,
      <<"{ \"v\":12345123456789}">>,
      #{<<"v">> => 12345123456789}},
     {bigint_number,
      <<"{ \"v\":123456789123456789123456789}">>,
      #{<<"v">> => 123456789123456789123456789}},
     {simple_digit_array,
      <<"[ 1,2,3,4]">>,
      [1,2,3,4]},
     {simple_string_array,
      <<"[ \"1\",\"2\",\"3\",\"4\"]">>,
      [<<"1">>,<<"2">>,<<"3">>,<<"4">>]},
     {array_of_empty_objects,
      <<"[ { }, { },[]]">>,
      [#{}, #{}, []]},
     {lowercase_unicode_text,
      <<"{ \"v\":\"\\uc3b8 & \\uc2a9\"}">>,
      #{<<"v">> => <<"ø & ©"/utf8>>}},
     {uppercase_unicode_text,
      <<"{ \"v\":\"\\uC3B8 & \\uC2A9\"}">>,
      #{<<"v">> => <<"ø & ©"/utf8>>}},
     {lowercase_non_unicode_encoded,
      <<"{ \"v\":\"\\u003e\"}">>,
      #{<<"v">> => <<">">>}},
     {uppercase_non_unicode_encoded,
      <<"{ \"v\":\"\\u003E\"}">>,
      #{<<"v">> => <<">">>}},
     {non_protected_text,
      <<"{ \"a\":\"hp://foo\"}">>,
      #{<<"a">> => <<"hp://foo">>}},
     {null,
      <<"{ \"a\":null}">>,
      #{<<"a">> => null}},
     {boolean,
      <<"{ \"a\":true}">>,
      #{<<"a">> => true}},
     {non_trimmed_data,
      <<"{ \"a\" : false }">>,
      #{<<"a">> => false}},
     {double_precision_float,
      <<"{ \"v\":1.7976931348623157E308}">>,
      #{<<"v">> => 1.7976931348623157e308}},
     {string_with_escape_chars,
      <<"{\"escaped_string\": \"\\t\\n\\r\\f\\b\\\\\\/\\\"\"}">>,
      #{<<"escaped_string">> => <<"\t\n\r\f\b\\/\"">>}}].

json_strings_should_fail() ->
    [{truncated_value, "{\"X\":\"s"},
     {truncated_key, "{\"X"}].

test_decode({_Type, Data, Expected}) ->
    ?assertEqual(Expected, lejson:decode(Data)).

test_encode({_Type, _Data, _Expected}) ->
    test_encode_decode(simple_json()).

test_encode_decode(Json) ->
    Map = lejson:decode(Json),
    NewJson = lejson:encode(Map),
    Map == lejson:decode(NewJson).

simple_json() ->
    "{\"boolean\": [true, false],"
    "\"neg_num\": -12,"
    "\"floats\": [-22.3, -22.3e-12, 22.3E-12, 22.3E+4, 22.3E+4, 22.3E4],"
    "\"null\": null,"
    "\"pos_int\": 6789,"
    "\"string_value\": \"value\","
    "\"string_with_escape_chars\": \"\\t\\n\\r\\f\\b\\\\\\/\\\"\","
    "\"utf_value\": \"\\uC3B8 and \\uc2a9\","
    "\"arabic\": \"\\uD8B3\\ud8b5\\ud8b8\","
    "\"more unicode\": \" \\uD834 \\uDD1E \","
    "\"array\": [{\"object_inside_array\": 1}],"
    "\"nested_array\": [[[79]]],"
    "\"another_array\": [1,2,3,[1,[2],3],12]}".

