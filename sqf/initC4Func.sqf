

player addEventHandler ["Fired",{
	if ((_this select 4) isKindOf "Dr_C4") then {
		_this spawn Dr_fnc_throwObject;
	};
}];

InActivateC4 = false;
MyC4 = [];
LastC4 = objNull;

["DrMods", "Shot", ["Подрыв", "Кнопка Подрыва всех С4"], {
	[] spawn Dr_fnc_ExplodeC4;
}, {}, [0x2E, [true, false, false]]] call CBA_fnc_addKeybind;
	
Dr_fnc_ExplodeC4 = {
	scriptName "Dr_fnc_Explode";
	if (InActivateC4) exitWith {};
	InActivateC4 = true;
	player playAction "Dr_explodeC4";
	UiSleep 1;
	player say3D "DrC4trigger";
	{
		"DrC4Shot" createVehicle (getpos _x);
		deleteVehicle _x;
	} forEach MyC4;
	MyC4 = []; 
	InActivateC4 = false;
};

Dr_fnc_throwObject = {
	scriptName "Dr_fnc_throwObject";
	private["_unit","_ammo","_distance","_weapon","_projectile","_doWait"];
	_unit = _this select 0;
	_weapon = _this select 1;
	_ammo = _this select 4;
	_projectile = _this select 6;

	_mollyPos = getPosATL _projectile;

	for "_i" from 0 to 1 step 0 do {
		if (!(alive _projectile)) exitWith {};
		if (((velocity _projectile) distance [0,0,0]) < 0.1) exitWith {};
		if !(isNull _projectile) then {
		    _mollyPos = getPosATL _projectile;
		};
		Uisleep 0.01;
	};
	_vehclass = "Dr_C4_obj";
	if (_ammo == "Dr_C4_Timed") then {
		_vehclass = "Dr_C4_Timed_obj";
	};
	_obj = _vehclass createVehicle _mollyPos;
	_obj setPosATL _mollyPos;
	MyC4 pushback _obj;
	if (_ammo == "Dr_C4_Timed") then {
		[_obj] spawn {
			_obj = _this select 0;
			for "_i" from 1 to 6 do {
				playSound3D ["Dr_C4\sounds\c4_beep_loop.wav",_obj,false,getPosASL _obj,1,1,20];
				UiSleep 1;
			};
			"DrC4Shot" createVehicle (getpos _obj);
			deleteVehicle _obj;
		};
	};
	_info = [_obj] call Dr_fnc_CheckModelPos;
	LastC4 = _obj;
};

Dr_fnc_CheckModelPos = {
	scriptName "Dr_fnc_CheckModelPos";
	_obj = _this select 0;
	_secCheck = param [1,false];
	_secChecknum = param [2,0];
	_iterations = param [3,0];
	_info = [];
	
	if (_secCheck) exitWith {
		_poss = _obj modelToWorld (_obj selectionPosition "center");
		_poss2 = _obj modelToWorld (_obj selectionPosition "downshort");
		
		_intersect = lineIntersectsSurfaces [(AGLtoASL _poss), (AGLtoASL _poss2),_obj] param [0,[]];
		
		if (_intersect isEqualTo []) then {
			_check = [];
			switch (true) do {
				switch (true) do {
				case (_secChecknum isEqualTo 0) : {
					_check = ["front","back"];
					_secChecknum = 2;
				};
				case (_secChecknum isEqualTo 1) : {
					_check = ["left","right"];
					_secChecknum = 3;
				};
				case (_secChecknum isEqualTo 2) : {
					_check = ["back","front"];
					_secChecknum = 0;
				};
				case (_secChecknum isEqualTo 3) : {
					_check = ["right","left"];
					_secChecknum = 1;
				};
			};
			};
			_iterations = _iterations + 1;
			_poss = _obj modelToWorld (_obj selectionPosition (_check select 0));
			_poss2 = _obj modelToWorld (_obj selectionPosition (_check select 1));
			_intersect = (lineIntersectsSurfaces [(AGLtoASL _poss), (AGLtoASL _poss2),_obj] param [0,[]]);
			_info = _intersect param [1,[]];
			_pos = _intersect param [0,[]];
			_objatt = _intersect param [3,[]];
			if (_iterations > 5) exitWith {
				
			};
			if (_info isEqualTo []) exitWith {
				[_obj,true,_secChecknum,_iterations] spawn Dr_fnc_CheckModelPos;
			};
			_obj attachTo [_objatt];
			_obj setDir 360;
			UiSleep 0.1;
			_obj setVectorUp _info;
		};
		[]
	};
	_type = 0;
	_intersect1 = [];
	_intersect2 = [];
	{
		_poss = _obj modelToWorld (_obj selectionPosition (_x select 0));
		_poss2 = _obj modelToWorld (_obj selectionPosition (_x select 1));
		_intersect1 = lineIntersectsSurfaces [(AGLtoASL _poss), (AGLtoASL _poss2),_obj] param [0,[]];
		if !(_intersect1 isEqualTo []) exitWith {
			_type = _forEachIndex;
			_posc1 = (_intersect1 select 0) distance _obj;
			_poss = _obj modelToWorld (_obj selectionPosition (_x select 1));
			_poss2 = _obj modelToWorld (_obj selectionPosition (_x select 0));
			_intersect2 = lineIntersectsSurfaces [(AGLtoASL _poss), (AGLtoASL _poss2),_obj] param [0,[]];
			_posc2 = (_intersect2 select 0) distance _obj;
			if (_posc2 > _posc1) then {
				_info = _intersect1;
			} else {
				_info = _intersect2;
			};
		};
	} forEach [["back","front"],["left","right"]];
	_obj setPosASL (_info select 0);
	_objtoatt = _info param [3,objNull];
	if (_objtoatt isKindOf "AllVehicles") then {
		_obj attachTo [_objtoatt];
	};
	_obj setDir 360;
	if ((_info param [1,[]]) isEqualTo []) exitWith {};
	_obj setVectorUp (_info select 1);
	[_obj,true,_type] spawn Dr_fnc_CheckModelPos;
};


