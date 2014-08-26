-module(setone).
-export([hextobase64/1, hexstr_to_bin/1, b64/1, ascii_to_b64/1, b64_to_ascii/1]).

-include("base64_table.hrl").

%% HEX STRING INPUT -> BASE64 Output, list and bin
hextobase64(Input) when is_binary(Input) ->
    HexBin = hexstr_to_bin(binary_to_list(Input)),
    b64_string(b64(HexBin));

hextobase64(Input) when is_list(Input) ->
    HexBin = hexstr_to_bin(Input),
    binary_to_list(b64_string(b64(HexBin))).
%% -------

%% ASCII STRING INPUT TO BASE64 Output, list and bin
ascii_to_b64(In) when is_binary(In) ->
    b64_string(b64(In));
ascii_to_b64(In) when is_list(In) ->
    binary_to_list(b64_string(b64(list_to_binary(In)))).
%% --


%% hexstring list to binary
hexstr_to_bin(S) ->
    hexstr_to_bin(S, []).

hexstr_to_bin([], Acc) ->
    list_to_binary(lists:reverse(Acc));

hexstr_to_bin([X,Y | T], Acc) ->
    {ok, [V], []} = io_lib:fread("~16u", [X, Y]),
    hexstr_to_bin(T, [V | Acc]).
%% --

%% converts octets to sextets, i.e. 8 bit ascii to 6 bit base64 chars
b64(Hex)->
    b64(Hex, [], []).

b64(<<>>, Acc, Pads) ->
    case Pads of
	dpad -> [Z1, Z2 | T] = Acc,
		lists:reverse(["=","=" | T]);
	spad -> [Z1 | T] = Acc,
		lists:reverse(["=" | T]);
	_ ->    lists:reverse(Acc)
	end;


b64(<<A:8>>, Acc, Pads) ->
    b64(<<A, 0, 0>>, Acc, dpad);


b64(<<A:8, B:8>>, Acc, Pads) ->
    b64(<<A, B, 0>>, Acc, spad);

b64(<<W:6, X:6, Y:6, Z:6, Rest/binary>>, Acc, Pads) ->
    b64(Rest, [Z,Y,X,W | Acc], Pads).


%% takes the list of sextets and uses lookup table B64Dict to get a string representation.
b64_string(Sexlets) ->
    b64_string(Sexlets, []).

b64_string([], Acc) ->
    list_to_binary(lists:reverse(Acc));
b64_string([H | T], Acc) ->
    B64Dict = sextet_base64_map(),
    b64_string(T, [maps:get(H, B64Dict) | Acc]).



%% PAST HERE IS IN PROGRESS, getting base64 string -> ascii

b64_to_ascii(In) when is_list(In) ->
    binary_to_list(b64_process(In));

b64_to_ascii(In) when is_binary(In) ->
    b64_process(In).

b64_process(L) when is_list(L) ->
    b64_process(L, []);
b64_process(L) when is_binary(L) ->
    b64_process(binary_to_list(L), []).

b64_process([], Acc) ->
    ascii(list_to_binary(lists:reverse(Acc)));
    %lists:reverse(Acc);
b64_process([H | T], Acc) ->
    RevB64Dict = base64_to_sextet_map(),
    b64_process(T, [maps:get([H], RevB64Dict) | Acc]).

ascii(Sextets) ->
    ascii(Sextets, []).

ascii(Sextets, Acc) ->
    W = << <<X:6>> || <<X:8>> <= Sextets >>,
    W.
    
% ascii(T, Acc2).
    
   
%% BQBQ3 = << <<X>> || <<X:8>> <= <<18:6,18:6,29:6,45:6>> >>. 
%% <<"I'm">>
