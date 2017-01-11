% CPSC 312 - 2016 - Project 1 - Preliminary Draft
% Avery Beardmore, Adrian Palidis and Roxy Promhouse
% Properties for Ryu (character).

% Some higher-level properties, to show how the program might be
% expanded to fit other characters.
% prop(street_fighter_2_turbo,character, ryu).
% prop(ryu, move_list,
% [close_standing_jab,far_standing_jab,crouching_jab,close_standing_strong,far_standing_strong,crouching_strong,close_standing_fierce,far_standing_fierce,crouching_fierce,close_standing_short,far_standing_short,crouching_short,close_standing_forward,far_standing_forward,crouching_forward,close_standing_roundhouse,far_standing_roundhouse,crouching_roundhouse]).

% Optional Static Game-State Properties (dif levels of usability)
% - idea is to mimic settings options in training mode of game
% - any of these could also be added as parameters to best_counter()
%   easily if that UI method seems better.
% - commented out properties are not active in training settings.

% Meter Properties (for player1)
game_state(special,meter,empty).
%game_state(special,meter,full).

% Character Properties
game_state(player1,state,ground).
game_state(player2,state,ground).
%game_state(player1,state,jumping).
%game_state(player2,state,jumping).


% Functions

% damage(Combo,Total) gives the total damage for a combo (list of moves)
damage([],0).
damage([M1|T], Total) :-
	move(M1,damage,X),
	damage(T, Y),
	Total is X + Y.

% can_counter(Range,Move1,Move2) is true if Move1 has a larger startup
% than Move2 ie. is true in the case that Move2 would 'hit first' if
% they were both done at the same time.
can_counter(Range,M1,M2):-
	move(M2,range,A),
	A>=Range,
	move(M1,startup_frame,X),
	move(M2,startup_frame,Y),
	X>Y.

% can_punish(Range,Move1,Move2) is true if Move2 has a smaller startup
% than Move1's recovery ie. is true when Move2 can be used to punish the
% opponent if they do a move and completely miss.
can_punish(Range,M1,M2):-
	move(M2,range,A),
	A>=Range,
	move(M2,startup_frame,X),
	move(M1,recovery_frame,Y),
	X>Y.

% can_combo(Range,Move1,Move2,Tolerance) is true if Move1 has an advantage >= Move2's
% startup - tolerance ie. if Move1 can be 'chained'(combo into) Move2.
can_combo(Range,M1,M2,Tol):-
	move(M1,knock_back,A),
	move(M2,range,B),
	B >= A+Range,
	move(M1,frame_advantage,X),
	move(M2,startup_frame,Y),
	X >= Y-Tol.


% generate_combo(Range, Move1, Tolerance, Combo) is true if Combo is a list of
% possible moves that can combo from Move1.
generate_combo(Range,_,_,[]):-
	Range >5.
generate_combo(Range,M1,Tol,[M2|T]):-
	can_combo(Range,M1,M2,Tol),
	move(M2,knock_back,A),
	generate_combo(Range+A,M2,Tol,T).

% counter(Range, P2 Action, Punishable, Tolerance, Combo, Damage)
% is true if the list Combo is a possible list of
% moves that chain together.
% The first move is guaranteed to beat Player2 Action.
% Tolerance is an integer >= 0 which represents the extra frames given
% between attacks without opponent counterattack
counter(Range,P2_Action,_,Tol,[P1_Action|P1_Next_Action],Damage):-
	can_counter(Range,P2_Action,P1_Action),
	move(P1_Action,knock_back,X),
	generate_combo(Range+X,P1_Action, Tol,P1_Next_Action),
	damage([P1_Action|P1_Next_Action],Damage).

% You can only find punishing moves if the move missed.
counter(Range,P2_Action,true,Tol,[P1_Action|P1_Next_Action],Damage):-
	can_punish(Range,P2_Action, P1_Action),
	move(P1_Action,knock_back,X),
	generate_combo(Range+X,P1_Action,Tol,P1_Next_Action),
	damage([P1_Action|P1_Next_Action],Damage).

better_counter(Range,P2_Action,Punish,Tol,D1):-
	counter(Range,P2_Action,Punish,Tol,_,BetterDam),
	BetterDam > D1.

best_counter(Range, P2_Action, Punish, Tol, Best, MaxDam) :-
	counter(Range, P2_Action, Punish, Tol, Best, MaxDam),
	\+ better_counter(Range, P2_Action,Punish,Tol,MaxDam).


%Demo test lines
%
% best_counter() will fail if the opponent's move lands (Punish ==
% false), and there are no moves available with a smaller start-up than
% the opponent's to counter with.
%    best_counter(4, far_standing_jab,false, 0, C, D).

% If the move does not miss (Punish == false),
% best_counter() will pass with a move available that has a smaller
% start-up than the opponent's
%     best_counter(4,far_standing_strong,false, 100, C,D).
%
% The following best_counter() tests describe combos (and the damage
% associated with those combos) that provide the best counter to the
% move passed as a parameter. The first move listed will be the move
% that has a smaller start-up than the opponent's recovery
%      best_counter(0,crouching_roundhouse,true, 100, C, D).
%      best_counter(1,far_standing_jab, true, 0, C, D).
%
% best_counter() may return more than one combo, if all combinations
% of moves all have the same damage
%      best_counter(1,far_standing_jab, true, 100, C, D).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Natural Language Engine? %%%%%%%%%%%%%%%%%%%%
% 1. How can Ryu punish Ken for whiffed standing forward?     %%
% 2. What is the best combo from Ryu close_standing_jab?      %%
% 3. Which one of Ryu's moves can beat Balrog's crouching_jab?%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Ground Normal Moves for Ryu.
% Range is represented with integers:
% (1=close,2=medium-close,3=medium,4=medium-far,5=far)
% this will make it easier to pass between functions and incrementally
% increase as more moves are used in a combo. Thus the opponent is
% getting knocked back further with each one.
% Assumption: 5 levels is necessary for adequate accuracy in the
% context of this project.
% Other data for moves can be found on the following website:
% http://wiki.shoryuken.com/Super_Street_Fighter_2_Turbo#Strategy

move(close_standing_jab,damage,4).
move(close_standing_jab,frame_advantage,4).
move(close_standing_jab,startup_frame,3).
move(close_standing_jab,active_frame,4).
move(close_standing_jab,recovery_frame,5).
move(close_standing_jab,special_cancel,true).
move(close_standing_jab,super_cancel,true).
move(close_standing_jab,chain_cancel,false).
move(close_standing_jab,type,normal).
move(close_standing_jab,position,ground).
move(close_standing_jab,range,1).
move(close_standing_jab,knock_back,1/2).

move(far_standing_jab,damage,4).
move(far_standing_jab,frame_advantage,4).
move(far_standing_jab,startup_frame,3).
move(far_standing_jab,active_frame,4).
move(far_standing_jab,recovery_frame,5).
move(far_standing_jab,special_cancel,true).
move(far_standing_jab,super_cancel,true).
move(far_standing_jab,chain_cancel,true).
move(far_standing_jab,type,normal).
move(far_standing_jab,position,ground).
move(far_standing_jab,range,2).
move(far_standing_jab,knock_back,1).

move(crouching_jab,damage,4).
move(crouching_jab,frame_advantage,4).
move(crouching_jab,startup_frame,3).
move(crouching_jab,active_frame,4).
move(crouching_jab,recovery_frame,5).
move(crouching_jab,special_cancel,true).
move(crouching_jab,super_cancel,true).
move(crouching_jab,chain_cancel,true).
move(crouching_jab,type,normal).
move(crouching_jab,position,ground).
move(crouching_jab,range,2).
move(crouching_jab,knock_back,1).

move(close_standing_strong,damage,22).
move(close_standing_strong,frame_advantage,-1).
move(close_standing_strong,startup_frame,4).
move(close_standing_strong,active_frame,4).
move(close_standing_strong,recovery_frame,7).
move(close_standing_strong,special_cancel,true).
move(close_standing_strong,super_cancel,true).
move(close_standing_strong,chain_cancel,false).
move(close_standing_strong,type,normal).
move(close_standing_strong,position,ground).
move(close_standing_strong,range,1).
move(close_standing_strong,knock_back,2).

move(far_standing_strong,damage,22).
move(far_standing_strong,frame_advantage,7).
move(far_standing_strong,startup_frame,4).
move(far_standing_strong,active_frame,4).
move(far_standing_strong,recovery_frame,7).
move(far_standing_strong,special_cancel,true).
move(far_standing_strong,super_cancel,true).
move(far_standing_strong,chain_cancel,false).
move(far_standing_strong,type,normal).
move(far_standing_strong,position,ground).
move(far_standing_strong,range,3).
move(far_standing_strong,knock_back,2).

move(crouching_strong,damage,22).
move(crouching_strong,frame_advantage,7).
move(crouching_strong,startup_frame,4).
move(crouching_strong,active_frame,4).
move(crouching_strong,recovery_frame,7).
move(crouching_strong,special_cancel,true).
move(crouching_strong,super_cancel,true).
move(crouching_strong,chain_cancel,false).
move(crouching_strong,type,normal).
move(crouching_strong,position,ground).
move(crouching_strong,range,3).
move(crouching_strong,knock_back,2).

move(close_standing_fierce,damage,28).
move(close_standing_fierce,frame_advantage,-7).
move(close_standing_fierce,startup_frame,4).
move(close_standing_fierce,active_frame,8).
move(close_standing_fierce,recovery_frame,23).
move(close_standing_fierce,special_cancel,false).
move(close_standing_fierce,super_cancel,true).
move(close_standing_fierce,chain_cancel,false).
move(close_standing_fierce,type,normal).
move(close_standing_fierce,position,ground).
move(close_standing_fierce,range,1).
move(close_standing_fierce,knock_back,2).

move(far_standing_fierce,damage,28).
move(far_standing_fierce,frame_advantage,-7).
move(far_standing_fierce,startup_frame,6).
move(far_standing_fierce,active_frame,6).
move(far_standing_fierce,recovery_frame,23).
move(far_standing_fierce,special_cancel,false).
move(far_standing_fierce,super_cancel,true).
move(far_standing_fierce,chain_cancel,false).
move(far_standing_fierce,type,normal).
move(far_standing_fierce,position,ground).
move(far_standing_fierce,range,3).
move(far_standing_fierce,knock_back,3).

move(crouching_fierce,damage,22).
move(crouching_fierce,frame_advantage,-9).
move(crouching_fierce,startup_frame,4).
move(crouching_fierce,active_frame,11).
move(crouching_fierce,recovery_frame,23).
move(crouching_fierce,special_cancel,false).
move(crouching_fierce,super_cancel,false).
move(crouching_fierce,chain_cancel,false).
move(crouching_fierce,type,normal).
move(crouching_fierce,position,ground).
move(crouching_fierce,range,2).
move(crouching_fierce,knock_back,3).

move(close_standing_short,damage,12).
move(close_standing_short,frame_advantage,3).
move(close_standing_short,startup_frame,6).
move(close_standing_short,active_frame,2).
move(close_standing_short,recovery_frame,8).
move(close_standing_short,special_cancel,false).
move(close_standing_short,super_cancel,true).
move(close_standing_short,chain_cancel,true).
move(close_standing_short,type,normal).
move(close_standing_short,position,ground).
move(close_standing_short,range,1).
move(close_standing_short,knock_back,1/2).

move(far_standing_short,damage,14).
move(far_standing_short,frame_advantage,0).
move(far_standing_short,startup_frame,5).
move(far_standing_short,active_frame,8).
move(far_standing_short,recovery_frame,5).
move(far_standing_short,special_cancel,true).
move(far_standing_short,super_cancel,true).
move(far_standing_short,chain_cancel,false).
move(far_standing_short,type,normal).
move(far_standing_short,position,ground).
move(far_standing_short,range,3).
move(far_standing_short,knock_back,1).

move(crouching_short,damage,4).
move(crouching_short,frame_advantage,0).
move(crouching_short,startup_frame,5).
move(crouching_short,active_frame,8).
move(crouching_short,recovery_frame,5).
move(crouching_short,special_cancel,true).
move(crouching_short,super_cancel,true).
move(crouching_short,chain_cancel,true).
move(crouching_short,type,normal).
move(crouching_short,position,ground).
move(crouching_short,range,2).
move(crouching_short,knock_back,1).

move(close_standing_forward,damage,24).
move(close_standing_forward,frame_advantage,3).
move(close_standing_forward,startup_frame,4).
move(close_standing_forward,active_frame,6).
move(close_standing_forward,recovery_frame,9).
move(close_standing_forward,special_cancel,true).
move(close_standing_forward,super_cancel,true).
move(close_standing_forward,chain_cancel,false).
move(close_standing_forward,type,normal).
move(close_standing_forward,position,ground).
move(close_standing_forward,range,1).
move(close_standing_forward,knock_back,2).

move(far_standing_forward,damage,24).
move(far_standing_forward,frame_advantage,3).
move(far_standing_forward,startup_frame,8).
move(far_standing_forward,active_frame,8).
move(far_standing_forward,recovery_frame,7).
move(far_standing_forward,special_cancel,false).
move(far_standing_forward,super_cancel,false).
move(far_standing_forward,chain_cancel,false).
move(far_standing_forward,type,normal).
move(far_standing_forward,position,ground).
move(far_standing_forward,range,4).
move(far_standing_forward,knock_back,2).

move(crouching_forward,damage,22).
move(crouching_forward,frame_advantage,3).
move(crouching_forward,startup_frame,4).
move(crouching_forward,active_frame,6).
move(crouching_forward,recovery_frame,9).
move(crouching_forward,special_cancel,false).
move(crouching_forward,super_cancel,false).
move(crouching_forward,chain_cancel,true).
move(crouching_forward,type,normal).
move(crouching_forward,position,ground).
move(crouching_forward,range,4).
move(crouching_forward,knock_back,2).

move(close_standing_roundhouse,damage,34).
move(close_standing_roundhouse,frame_advantage,6).
move(close_standing_roundhouse,startup_frame,8).
move(close_standing_roundhouse,active_frame,12).
move(close_standing_roundhouse,recovery_frame,11).
move(close_standing_roundhouse,special_cancel,false).
move(close_standing_roundhouse,super_cancel,false).
move(close_standing_roundhouse,chain_cancel,false).
move(close_standing_roundhouse,type,normal).
move(close_standing_roundhouse,position,ground).
move(close_standing_roundhouse,range,1).
move(close_standing_roundhouse,knock_back,3).

move(far_standing_roundhouse,damage,30).
move(far_standing_roundhouse,frame_advantage,-3).
move(far_standing_roundhouse,startup_frame,3).
move(far_standing_roundhouse,active_frame,12).
move(far_standing_roundhouse,recovery_frame,17).
move(far_standing_roundhouse,special_cancel,false).
move(far_standing_roundhouse,super_cancel,false).
move(far_standing_roundhouse,chain_cancel,false).
move(far_standing_roundhouse,type,normal).
move(far_standing_roundhouse,position,ground).
move(far_standing_roundhouse,range,5).
move(far_standing_roundhouse,knock_back,3).

move(crouching_roundhouse,damage,26).
move(crouching_roundhouse,frame_advantage,-9).
move(crouching_roundhouse,startup_frame,4).
move(crouching_roundhouse,active_frame,6).
move(crouching_roundhouse,recovery_frame,25).
move(crouching_roundhouse,special_cancel,true).
move(crouching_roundhouse,super_cancel,true).
move(crouching_roundhouse,chain_cancel,false).
move(crouching_roundhouse,type,normal).
move(crouching_roundhouse,position,ground).
move(crouching_roundhouse,range,5).
move(crouching_roundhouse,knock_back,7).%causes knockdown

% Special Moves
%
move(jab_hadouken,damage,18).
move(jab_hadouken,frame_advantage,-1).%couldnt find actual frame_advantage but i know from experience you cant combo after it, -1 will achieve this.
move(jab_hadouken,startup_frame,11).
move(jab_hadouken,active_frame,41).
move(jab_hadouken,recovery_frame,20).
move(jab_hadouken,special_cancel,false).
move(jab_hadouken,super_cancel,true).
move(jab_hadouken,chain_cancel,false).
move(jab_hadouken,type,special).
move(jab_hadouken,position,ground).
move(jab_hadouken,range,5).
move(jab_hadouken,knock_back, 10).

move(strong_hadouken,damage,20).
move(strong_hadouken,frame_advantage,-1).
move(strong_hadouken,startup_frame,11).
move(strong_hadouken,active_frame,42).
move(strong_hadouken,recovery_frame,20).
move(strong_hadouken,special_cancel,false).
move(strong_hadouken,super_cancel,true).
move(strong_hadouken,chain_cancel,false).
move(strong_hadouken,type,special).
move(strong_hadouken,position,ground).
move(strong_hadouken,range,5).
move(strong_hadouken,knock_back, 10).

move(fierce_hadouken,damage,22).
move(fierce_hadouken,frame_advantage,-1).
move(fierce_hadouken,startup_frame,11).
move(fierce_hadouken,active_frame,43).
move(fierce_hadouken,recovery_frame,20).
move(fierce_hadouken,special_cancel,false).
move(fierce_hadouken,super_cancel,true).
move(fierce_hadouken,chain_cancel,false).
move(fierce_hadouken,type,special).
move(fierce_hadouken,position,ground).
move(fierce_hadouken,range,6).
move(fierce_hadouken,knock_back, 10).

% Super Moves
move(shinkuu_hadouken,damage,80).
move(shinkuu_hadouken,frame_advantage,-1).
move(shinkuu_hadouken,startup_frame,10).
move(shinkuu_hadouken,active_frame,43).
move(shinkuu_hadouken,recovery_frame,40).
move(shinkuu_hadouken,special_cancel,false).
move(shinkuu_hadouken,super_cancel,false).
move(shinkuu_hadouken,chain_cancel,false).
move(shinkuu_hadouken,type,super).
move(shinkuu_hadouken,position,ground).
move(shinkuu_hadouken,range,7).
move(shinkuu_hadouken,knock_back, 10).
