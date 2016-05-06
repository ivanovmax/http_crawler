-module(http_crawler).
-export([start/1]).

start(Url) ->
	Root = extract_root(Url),
	case Root of
		error -> io:format("Empty root");
		_ -> spawn(http_reader, start, [Url, Root])
	end.

extract_root(Url) ->
	Res = re:split(Url, "(https?:\/\/[\da-z\.\-]+)[\/\w \.-]*\/?"),
	case [X || X <- Res, X /= <<>>, binary:part(X,0,4)==<<"http">>] of
		[] -> error;
		[H|_] -> H
	end.
