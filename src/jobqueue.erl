%% -*- erlang -*-
%
% Cuneiform: A Functional Language for Large Scale Scientific Data Analysis
%
% Copyright 2016 Jörgen Brandt, Marc Bux, and Ulf Leser
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

-module( jobqueue ).
-author( "Jorgen Brandt <brandjoe@hu-berlin.de>" ).
-behaviour( gen_server ).

%% =============================================================================
%% Function Exports
%% =============================================================================

-export( [start_link/0, start_link/1, stage_reply/2] ).

-export( [code_change/3, handle_cast/2, handle_info/2, init/1, terminate/2,
          handle_call/3] ).

%% =============================================================================
%% Type Definitions
%% =============================================================================

-type job()         :: {Mod::atom(), Fun::atom(), ArgLst::[term()]}.
-type request()     :: {request, pid(), job()}.
-type queue_state() :: {NSlot::non_neg_integer(), Q::[request()]}.

%% =============================================================================
%% Generic Server Functions
%% =============================================================================

code_change( _OldVsn, State, _Extra ) -> {ok, State}.
handle_call( Request, _From, _State ) -> error( {bad_request, Request} ).
terminate( _Reason, _State ) -> ok.
handle_info( Info, _State ) -> error( {bad_msg, Info} ).

-spec init( NSlot::pos_integer() ) -> {ok, queue_state()}.

init( NSlot ) -> {ok, {NSlot,[]}}.

-spec handle_cast( Request, State ) -> {noreply, queue_state()}
when Request :: request(),
     State   :: queue_state().

handle_cast( continue, {NSlot, []} ) ->
  {noreply, {NSlot+1, []}};

handle_cast( continue, {NSlot, [H|T]} ) ->
  stage_reply( self(), H ),
  {noreply, {NSlot, T}};

handle_cast( Request, {0, Q} ) ->
  {noreply, {0, [Request|Q]}};

handle_cast( Request, {NSlot, []} ) ->
  stage_reply( self(), Request ),
  {noreply, {NSlot-1, []}};

handle_cast( Request, _State ) ->
  error( {bad_request, Request} ).


%% =============================================================================
%% API Functions
%% =============================================================================

-spec start_link() -> {ok, pid()} | ignore | {error, term()}.

start_link() ->
  NSlot = erlang:system_info( logical_processors_available ),
  start_link( NSlot ).

-spec start_link( NSlot ) -> {ok, pid()} | ignore | {error, term()}
when NSlot :: pos_integer().

start_link( NSlot )
when is_integer( NSlot ), NSlot > 0 ->
  gen_server:start_link( ?MODULE, NSlot, [] ).

-spec stage_reply( QueueRef, Request ) -> ok
when QueueRef :: pid(),
     Request  :: request().

stage_reply( QueueRef, {request, Pid, {Mod, Fun, ArgLst}} )
when is_pid( QueueRef ),
     is_pid( Pid ),
     is_atom( Mod ),
     is_atom( Fun ),
     is_list( ArgLst ) ->
  Pid ! apply( Mod, Fun, ArgLst ),
  gen_server:cast( QueueRef, continue ).