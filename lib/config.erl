%% @author Johannes Huning <johannes.huning@wooga.net>
%% @author Diego Echeverri <diego.echeverri@wooga.net>
-module (config).
-compile (export_all).

% Returns the applications root directory.
app_root() ->
  Cmd = "cd " ++ filename:dirname(?FILE) ++ "/..; pwd | tr -d '\n'",
  case os:getenv("APP_ROOT") of
    false -> os:cmd(Cmd);
    Value -> Value
  end.

% Loads all configuration and environment settings from the appropriate
% .config file. See config/enviroments.
init() ->
  EnvConfig = app_root() ++ "/config/environments/" ++ atom_to_list(env()) ++ ".config",
  {ok, [Terms]} = file:consult(EnvConfig),

  LoadAppConfig = fun({App, PList}) ->
                      SetEnv = fun({Key, Value}) ->
                                   application:set_env(App, Key, Value)
                               end,
                      lists:foreach(SetEnv, PList)
                  end,
  lists:foreach(LoadAppConfig, Terms).

%% @doc Alias for environment.
env() -> environment().

%% @doc Returns the current environment running in.
environment() ->
  case os:getenv("APP_ENV") of
    false -> development;
    Value -> list_to_atom(Value)
  end.
