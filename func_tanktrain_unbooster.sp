#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required
#pragma semicolon 1

float gF_LastSpeed[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "func_tanktrain Unbooster",
	author = "Nickelony",
	description = "Makes func_tanktrain not give you an unfair boost after touching it.",
	version = "1.0",
	url = "http://steamcommunity.com/id/nickelony/"
};

public void OnMapStart()
{
	HookTouch();
}

void HookTouch()
{
	int ent = -1;
	
	while((ent = FindEntityByClassname(ent, "func_tanktrain")) != -1)
	{
		SDKHook(ent, SDKHook_Touch, Entity_Touch);
		SDKHook(ent, SDKHook_TouchPost, Entity_TouchPost);
	}
	
	ent = -1;
	
	while((ent = FindEntityByClassname(ent, "func_tracktrain")) != -1)
	{
		SDKHook(ent, SDKHook_Touch, Entity_Touch);
		SDKHook(ent, SDKHook_TouchPost, Entity_TouchPost);
	}
}

public int Entity_Touch(int entity, int client)
{
	if(client < 1 || client > MaxClients)
	{
		return;
	}
	
	if(!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}
	
	GetSpeed(client);
}

void GetSpeed(int client)
{
	float fVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVel);
	float fCurrentSpeed = SquareRoot(Pow(fVel[0], 2.0) + Pow(fVel[1], 2.0));
	
	gF_LastSpeed[client] = fCurrentSpeed;
}

public int Entity_TouchPost(int entity, int client)
{
	if(client < 1 || client > MaxClients)
	{
		return;
	}
	
	if(!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}
	
	SetSpeed(client);
}

void SetSpeed(int client)
{
	float fVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVel);
	float fCurrentSpeed = SquareRoot(Pow(fVel[0], 2.0) + Pow(fVel[1], 2.0));
	
	if(fCurrentSpeed > 0.0)
	{
		float x = fCurrentSpeed / gF_LastSpeed[client];
		
		fVel[0] /= x;
		fVel[1] /= x;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVel);
	}
}
