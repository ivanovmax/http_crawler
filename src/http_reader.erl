-module(http_reader).
-export([start/2]).

start(Url, RootUrl) ->
	inets:start(),
	handle_request(httpc:request(Url), RootUrl).

handle_request({ok, Result}, RootUrl) -> 
	check_status(Result, RootUrl);
handle_request({error, Reason}, _) ->
	io:format("Error: ~s~n",[Reason]).

valid_status(Status) when Status >= 200, Status < 300 ->
	true;
valid_status(_) ->
	false.

check_status({StatusCode, Body}, RootUrl) ->
	case valid_status(StatusCode) of
		true -> 
			Html = mochiweb_html:parse(Body),
			parse(Html, RootUrl);
		false -> io:format("Invalid http response code ~s~n",[StatusCode])
	end;

check_status({{_, StatusCode, _}, _Headers, Body}, RootUrl) ->
	check_status({StatusCode, Body}, RootUrl).

%re:run("/sss/ddd/ff/","^(\/[a-zA-Z]+)+\\/?").
%^(https?:\/\/[\da-z\.\-]+)[\/\w \.-]*\/?
%spawn(http_reader, start, [Href]);
handle_ref(Href, RootUrl) ->
	case re:run("/sss/ddd/ff/","^(\/[a-zA-Z]+)+\/?") of
		{match, _} -> 
			Url = RootUrl ++ Href,
			spawn(http_reader, start, [Url, RootUrl]);
		_ ->
			case binary:part(Href, 0, byte_size(RootUrl)) == RootUrl of
				true -> spawn(http_reader, start, [Href, RootUrl]);
				false -> io:format("Invalid URL")
			end
	end.

%parse({Tag, Attr, Child})

get_parser(RootUrl) ->
	fun(X) -> parse(X, RootUrl) end.

parse({<<"a">>, Attr, Child}, RootUrl) ->
	case lists:keyfind(<<"href">>, 1, Attr) of
		{_, Href} -> handle_ref(Href, RootUrl); 
		false -> io:format("Bad args")
	end,
	lists:foreach(get_parser(RootUrl), Child);

parse({_, _, Child}, RootUrl) ->
	lists:foreach(get_parser(RootUrl), Child).	

complete(Result) -> 
	lists:foreach(fun(Item) -> io:format("~s~n",[Item]) end, Result).

