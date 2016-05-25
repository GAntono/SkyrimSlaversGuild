Scriptname ssmMain extends Quest

; TODO: Have all properties & variables initiate via a function, to allow them to take new value after version update.

zbfSlaveControl Property SlaveControl Auto	; ZAZ Animation Pack zbfSlaveControl API.

ReferenceAlias Property PlayerRef Auto
ssmSlave[] Property Slots Auto
Spell Property ssmEnslaveSpell Auto
Int ssmMenuKey = 47	; V key.

; makes sure that OnInit() will only fire once.
Event OnInit()
	StorageUtil.AdjustIntValue(Self, "OnInitCounter", 1)
	If StorageUtil.GetIntValue(Self, "OnInitCounter") == 2
		SlaveControl.RegisterForEvents()
		PlayerRef.GetActorReference().AddSpell(ssmEnslaveSpell)
		RegisterForKey(ssmMenuKey)

		StorageUtil.UnsetIntValue(Self, "OnInitCounter")
		Debug.Trace("[SSM] Initialized")
	EndIf
EndEvent

ssmSlave Function FindSlot(Actor akActor)
	If !akActor
		Return None
	EndIf

	Int i
	While i < Slots.Length
		If Slots[i].GetReference() == akActor
			Return Slots[i]
		EndIf
		i += 1
	EndWhile
	Return None
EndFunction

ssmSlave Function SlotActor(Actor akActor)
	If !akActor
		Return None
	EndIf

	ssmSlave returnSlot = FindSlot(akActor)
	Int i
	While returnSlot == None && i < Slots.Length
		If Slots[i].GetReference() == None
			Slots[i].ForceRefTo(akActor)
			returnSlot = Slots[i]
		EndIf
		i += 1
	EndWhile
	Return returnSlot
EndFunction

Event OnKeyDown(Int Keycode)
	If keycode == ssmMenuKey && Utility.IsInMenuMode() == False
		ObjectReference crossHairRef = Game.GetCurrentCrosshairRef()
		If crossHairRef != None && SlaveControl.IsSlave(crossHairRef as Actor)
			Actor slave = crossHairRef as Actor
			UIExtensions.InitMenu("UIWheelMenu")
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 0, "Equip")
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionText", 1, "Inventory")
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 0, "Equip")
			UIExtensions.SetMenuPropertyIndexString("UIWheelMenu", "optionLabelText", 1, "Inventory")
			UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 0, True)
			UIExtensions.SetMenuPropertyIndexBool("UIWheelMenu", "optionEnabled", 1, True)
			Int ssmMenuSelected = UIExtensions.OpenMenu("UIWheelMenu", slave)
			Debug.Trace("[SSM] Option " + ssmMenuSelected + " selected")
			If ssmMenuSelected == 0
				FindSlot(slave).bForceEquip = True	; bForceEquip is a property in the ssmSlave sub-class of Actor
				slave.OpenInventory(abForceOpen = True)
			ElseIf ssmMenuSelected == 1
				FindSlot(slave).bForceEquip = False
				slave.OpenInventory(abForceOpen = True)
			EndIf
		EndIf
	EndIf
EndEvent
