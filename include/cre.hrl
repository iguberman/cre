% The Cuneiform Runtime Environment is an interpreter of the functional
% programming language Cuneiform.
%
% Copyright 2013-2015 Jörgen Brandt, Marc Bux, and Ulf Leser
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


% supervisor callback functions

-spec init( [] ) -> {ok, {supervisor:sup_flags(), [supervisor:child_spec()]}}.


% application callback functions

-spec start( normal, [] ) -> {ok, pid()}.
-spec stop( term() ) -> ok.


% convenience functions

-spec start_link() -> {ok, pid()}.


% interface functions

-spec file( Filename::string(), Datadir::string() ) -> {ok, pid()}.
