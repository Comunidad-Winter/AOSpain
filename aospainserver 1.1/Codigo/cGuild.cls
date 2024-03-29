VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cGuild"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'Argentum Online 0.9.0.2
'Copyright (C) 2002 M�rquez Pablo Ignacio
'
'This program is free software; you can redistribute it and/or modify
'it under the terms of the GNU General Public License as published by
'the Free Software Foundation; either version 2 of the License, or
'any later version.
'
'This program is distributed in the hope that it will be useful,
'but WITHOUT ANY WARRANTY; without even the implied warranty of
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'GNU General Public License for more details.
'
'You should have received a copy of the GNU General Public License
'along with this program; if not, write to the Free Software
'Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
'
'Argentum Online is based on Baronsoft's VB6 Online RPG
'You can contact the original creator of ORE at aaron@baronsoft.com
'for more information about ORE please visit http://www.baronsoft.com/
'
'
'You can contact me at:
'morgolock@speedy.com.ar
'www.geocities.com/gmorgolock
'Calle 3 n�mero 983 piso 7 dto A
'La Plata - Pcia, Buenos Aires - Republica Argentina
'C�digo Postal 1900
'Pablo Ignacio M�rquez
Option Explicit

'this member variables should be private.. but i
'dont have enough time to write the four methods that
'requires each of them to query and update ....

Public ElectionPeriod  As Long


Public Founder As String
Public FundationDate As String
Public Description As String
Private codex(0 To 7) As String
Public leader As String
Public Reputation As Double
Public Gold As Double
Public GuildName As String
Public URL As String
Public GuildExperience As Double
Public DaysSinceLastElection As Long
Public GuildNews As String

Public AlliedGuilds As Collection
Public EnemyGuilds As Collection
Public Members As Collection
Public Solicitudes As Collection
Public PeacePropositions As Collection
Public Votes As Collection
Public Elections As Boolean

Private Type tVotes
        Name As String
        Cant As Long
End Type


Public Function GetCodex(ByVal Number As Byte) As String
GetCodex = codex(Number)
End Function

Public Function CodexLenght() As Integer
Dim t%
For t% = 0 To 7
    If codex(t%) = "" Then Exit For
    If t% = 7 Then Exit For
Next t%

CodexLenght = t%
End Function

Public Function DaysToNextElection() As Integer
DaysToNextElection = ElectionPeriod - DaysSinceLastElection
End Function

Private Function TestName(ByVal cad As String) As Boolean
Dim car As Byte
Dim i As Integer

cad = LCase$(cad)

For i = 1 To Len(cad)
    car = Asc(Mid$(cad, i, 1))
    
    If (car < 97 Or car > 122) And (car <> 255) And (car <> 32) Then
        TestName = False
        Exit Function
    End If
    
Next i

TestName = True

End Function

Public Sub UpdateCodexAndDesc(ByVal rdata As String)

Description = ReadField(1, rdata, Asc("�"))

Dim Mandamientos As Integer
Mandamientos = CInt(ReadField(2, rdata, Asc("�")))

Dim i As Integer
For i = 1 To Mandamientos
    codex(i - 1) = ReadField(2 + i, rdata, Asc("�"))
Next i


End Sub

Private Function ParseGuildInfo(ByRef GuildInfo As String, ByVal FounderName As String, ByVal Rep As Long) As Boolean

On Err GoTo errhandler

Founder = FounderName
leader = Founder
FundationDate = Now
Description = ReadField(1, GuildInfo, Asc("�"))
GuildName = ReadField(2, GuildInfo, Asc("�"))

If Not TestName(GuildName) Then
    ParseGuildInfo = False
    Exit Function
End If

URL = ReadField(3, GuildInfo, Asc("�"))
Dim Mandamientos As Integer
Mandamientos = CInt(ReadField(4, GuildInfo, Asc("�")))
Dim i As Integer
For i = 1 To Mandamientos
    codex(i - 1) = ReadField(4 + i, GuildInfo, Asc("�"))
Next i
Reputation = Rep
Gold = 0
GuildExperience = 0
DaysSinceLastElection = 0
GuildNews = "Clan iniciado."

ParseGuildInfo = True

Exit Function

errhandler:

End Function

Public Sub InitializeGuildFromDisk(ByVal Number As Integer)
Dim file As String

file = App.Path & "\Guilds\" & "GuildsInfo.inf"

GuildName = GetVar(file, "Guild" & Number, "GuildName")
Founder = GetVar(file, "Guild" & Number, "Founder")
FundationDate = GetVar(file, "Guild" & Number, "Date")
Description = GetVar(file, "Guild" & Number, "Desc")
codex(0) = GetVar(file, "Guild" & Number, "Codex0")
codex(1) = GetVar(file, "Guild" & Number, "Codex1")
codex(2) = GetVar(file, "Guild" & Number, "Codex2")
codex(3) = GetVar(file, "Guild" & Number, "Codex3")
codex(4) = GetVar(file, "Guild" & Number, "Codex4")
codex(5) = GetVar(file, "Guild" & Number, "Codex5")
codex(6) = GetVar(file, "Guild" & Number, "Codex6")
codex(7) = GetVar(file, "Guild" & Number, "Codex7")
leader = GetVar(file, "Guild" & Number, "Leader")
Reputation = val(GetVar(file, "Guild" & Number, "Rep"))
Gold = val(GetVar(file, "Guild" & Number, "Gold"))
URL = GetVar(file, "Guild" & Number, "URL")
GuildExperience = val(GetVar(file, "Guild" & Number, "Exp"))
DaysSinceLastElection = val(GetVar(file, "Guild" & Number, "DaysLast"))
GuildNews = GetVar(file, "Guild" & Number, "GuildNews")


Call LoadGuildMembers(GuildName)
Call LoadSolicitudes(GuildName)
Call LoadAlliedGuilds(GuildName)
Call LoadEnemyGuilds(GuildName)
Call LoadPeacePropositions(GuildName)

End Sub


Private Sub LoadGuildMembers(ByVal GuildName As String)

Dim f As String

f = App.Path & "\Guilds\" & GuildName & "-Members" & ".mem"


Dim t As Long
t = val(GetVar(f, "INIT", "NroMembers"))

Dim j As Integer

For j = 1 To t
    Call Members.Add(GetVar(f, "Members", "Member" & j))
Next j


End Sub

Private Sub LoadSolicitudes(ByVal GuildName As String)

Dim f As String

f = App.Path & "\Guilds\" & GuildName & "-Solicitudes" & ".sol"


Dim t As Long
t = val(GetVar(f, "INIT", "Nro"))

If t > 25 Then Exit Sub

Dim j As Integer
Dim sol As cSolicitud
For j = 1 To t
    Set sol = New cSolicitud
    sol.UserName = GetVar(f, "Sol" & j, "Name")
    sol.Desc = GetVar(f, "Sol" & j, "Desc")
    Call Solicitudes.Add(sol)
Next j


End Sub

Private Sub LoadPeacePropositions(ByVal GuildName As String)

Dim f As String

f = App.Path & "\Guilds\" & GuildName & "-Propositions" & ".pro"

Dim t As Long

t = val(GetVar(f, "INIT", "Nro"))

Dim j As Integer
Dim sol As cSolicitud
For j = 1 To t
    Set sol = New cSolicitud
    sol.UserName = GetVar(f, "Sol" & j, "Name")
    sol.Desc = GetVar(f, "Sol" & j, "Desc")
    Call PeacePropositions.Add(sol)
Next j


End Sub




Private Sub SaveAlliedGuilds(ByVal GuildName As String)

Dim f As String

f = App.Path & "\Guilds\" & GuildName & "-Allied" & ".all"

If FileExist(f, vbNormal) Then Kill f

Call WriteVar(f, "INIT", "NroAllies", AlliedGuilds.Count)

Dim j As Integer

For j = 1 To AlliedGuilds.Count
    Call WriteVar(f, "Allies", "Allie" & j, AlliedGuilds(j))
Next j

End Sub


Private Sub LoadAlliedGuilds(ByVal GuildName As String)

Dim f As String

f = App.Path & "\Guilds\" & GuildName & "-Allied" & ".all"


Dim t As Long
t = val(GetVar(f, "INIT", "NroAllies"))

Dim j As Integer

For j = 1 To t
    Call AlliedGuilds.Add(GetVar(f, "Allies", "Allie" & j))
Next j


End Sub



Private Sub SaveEnemyGuilds(ByVal GuildName As String)

Dim f As String

f = App.Path & "\Guilds\" & GuildName & "-Enemys" & ".ene"

If FileExist(f, vbNormal) Then Kill f

Call WriteVar(f, "INIT", "NroEnemys", EnemyGuilds.Count)

Dim j As Integer

For j = 1 To EnemyGuilds.Count
    Call WriteVar(f, "Enemys", "Enemy" & j, EnemyGuilds(j))
Next j

End Sub


Private Sub LoadEnemyGuilds(ByVal GuildName As String)

Dim f As String

f = App.Path & "\Guilds\" & GuildName & "-Enemys" & ".ene"


Dim t As Long
t = val(GetVar(f, "INIT", "NroEnemys"))

Dim j As Integer

For j = 1 To t
    Call AlliedGuilds.Add(GetVar(f, "Enemys", "Enemy" & j))
Next j


End Sub


Private Sub SaveGuildMembers(ByVal GuildName As String)

Dim f As String

f = App.Path & "\Guilds\" & GuildName & "-Members" & ".mem"

If FileExist(f, vbNormal) Then Kill f

Call WriteVar(f, "INIT", "NroMembers", Members.Count)

Dim j As Integer

For j = 1 To Members.Count
    Call WriteVar(f, "Members", "Member" & j, Members(j))
Next j


End Sub

Private Sub SaveSolicitudes(ByVal GuildName As String)

Dim f As String

f = App.Path & "\Guilds\" & GuildName & "-Solicitudes" & ".sol"

If FileExist(f, vbNormal) Then Kill f

Call WriteVar(f, "INIT", "Nro", Solicitudes.Count)

Dim j As Integer

For j = 1 To Solicitudes.Count
    Call WriteVar(f, "Sol" & j, "Name", Solicitudes(j).UserName)
    Call WriteVar(f, "Sol" & j, "Desc", Solicitudes(j).Desc)
Next j


End Sub

Private Sub SavePeacePropositions(ByVal GuildName As String)

Dim f As String

f = App.Path & "\Guilds\" & GuildName & "-Propositions" & ".pro"

If FileExist(f, vbNormal) Then Kill f

Call WriteVar(f, "INIT", "Nro", PeacePropositions.Count)

Dim j As Integer

For j = 1 To PeacePropositions.Count
    Call WriteVar(f, "Pro" & j, "Name", PeacePropositions(j).UserName)
    Call WriteVar(f, "Pro" & j, "Desc", PeacePropositions(j).Desc)
Next j


End Sub


Public Sub SaveGuild(ByVal file As String, ByVal GuildNumber)

On Error GoTo errhandler



Call WriteVar(file, "GUILD" & GuildNumber, "GuildName", GuildName)
Call WriteVar(file, "GUILD" & GuildNumber, "Founder", Founder)
Call WriteVar(file, "GUILD" & GuildNumber, "GuildName", GuildName)
Call WriteVar(file, "GUILD" & GuildNumber, "Date", FundationDate)
Call WriteVar(file, "GUILD" & GuildNumber, "Desc", Description)
Call WriteVar(file, "GUILD" & GuildNumber, "Codex0", codex(0))
Call WriteVar(file, "GUILD" & GuildNumber, "Codex1", codex(1))
Call WriteVar(file, "GUILD" & GuildNumber, "Codex2", codex(2))
Call WriteVar(file, "GUILD" & GuildNumber, "Codex3", codex(3))
Call WriteVar(file, "GUILD" & GuildNumber, "Codex4", codex(4))
Call WriteVar(file, "GUILD" & GuildNumber, "Codex5", codex(5))
Call WriteVar(file, "GUILD" & GuildNumber, "Codex6", codex(6))
Call WriteVar(file, "GUILD" & GuildNumber, "Codex7", codex(7))
Call WriteVar(file, "GUILD" & GuildNumber, "Leader", leader)
Call WriteVar(file, "GUILD" & GuildNumber, "URL", URL)
Call WriteVar(file, "GUILD" & GuildNumber, "GuildExp", Str(GuildExperience))
Call WriteVar(file, "GUILD" & GuildNumber, "DaysLast", Str(DaysSinceLastElection))
Call WriteVar(file, "GUILD" & GuildNumber, "GuildNews", GuildNews)
Call WriteVar(file, "GUILD" & GuildNumber, "Rep", Str(Reputation))

Call SaveAlliedGuilds(GuildName)
Call SaveEnemyGuilds(GuildName)
Call SaveGuildMembers(GuildName)
Call SaveSolicitudes(GuildName)
Call SavePeacePropositions(GuildName)

Exit Sub

errhandler:


End Sub

Public Function Initialize(ByVal GuildInfo As String, ByVal FounderName As String, ByVal Rep As Long) As Boolean
Initialize = ParseGuildInfo(GuildInfo, FounderName, Rep)
End Function

Private Sub Class_Initialize()

Set AlliedGuilds = New Collection
Set EnemyGuilds = New Collection
Set Members = New Collection
Set Solicitudes = New Collection
Set PeacePropositions = New Collection
Set Votes = New Collection

ElectionPeriod = 45

End Sub

Public Function IsEnemy(ByVal GuildName As String) As Boolean

Dim k As Integer

GuildName = UCase$(GuildName)

For k = 1 To EnemyGuilds.Count
    If UCase$(EnemyGuilds(k)) = GuildName Then
            IsEnemy = True
            Exit Function
    End If
Next k

End Function


Public Function IsAllie(ByVal GuildName As String) As Boolean

Dim k As Integer

GuildName = UCase$(GuildName)

For k = 1 To AlliedGuilds.Count
    If UCase$(AlliedGuilds(k)) = GuildName Then
            IsAllie = True
            Exit Function
    End If
Next k

End Function

Public Function SolicitudesIncludes(ByVal UserName As String) As Boolean

Dim k As Integer


UserName = UCase$(UserName)

For k = 1 To Solicitudes.Count
    If UCase$(Solicitudes(k).UserName) = UserName Then
            SolicitudesIncludes = True
            Exit Function
    End If
Next k


End Function

Public Sub RemoveSolicitud(ByVal UserName As String)

Dim k As Integer


UserName = UCase$(UserName)

For k = 1 To Solicitudes.Count
    If UCase$(Solicitudes(k).UserName) = UserName Then
            Call Solicitudes.Remove(k)
            Exit Sub
    End If
Next k



End Sub

Public Sub RemoveProposition(ByVal UserName As String)

Dim k As Integer


UserName = UCase$(UserName)

For k = 1 To PeacePropositions.Count
    If UCase$(PeacePropositions(k).UserName) = UserName Then
            Call PeacePropositions.Remove(k)
            Exit Sub
    End If
Next k



End Sub


Public Sub RemoveAllie(ByVal Name As String)
Dim k As Integer
Name = UCase$(Name)
For k = 1 To AlliedGuilds.Count
    If UCase$(AlliedGuilds(k)) = Name Then
            Call AlliedGuilds.Remove(k)
            Exit Sub
    End If
Next k
End Sub

Public Sub RemoveEnemy(ByVal Name As String)
Dim k As Integer
Name = UCase$(Name)
For k = 1 To EnemyGuilds.Count
    If UCase$(EnemyGuilds(k)) = Name Then
            Call EnemyGuilds.Remove(k)
            Exit Sub
    End If
Next k
End Sub


Public Sub RemoveMember(ByVal UserName As String)

Dim k As Integer


UserName = UCase$(UserName)

For k = 1 To Members.Count
    If UCase$(Members(k)) = UserName Then
            Call Members.Remove(k)
            Exit Sub
    End If
Next k



End Sub





Public Function GetPeaceRequest(ByVal UserName As String) As cSolicitud

Dim k As Integer


UserName = UCase$(UserName)

For k = 1 To PeacePropositions.Count
    If UCase$(PeacePropositions(k).UserName) = UserName Then
            Set GetPeaceRequest = PeacePropositions(k)
            Exit Function
    End If
Next k


End Function


Public Sub TestSolicitudBound()
'Nos aseguramos que no halla m�s de 25 solicitudes
If Me.Solicitudes.Count > 25 Then
    Dim i As Integer
    For i = 1 To Me.Solicitudes.Count
        Solicitudes.Remove 1
    Next i
End If
End Sub

Public Function GetSolicitud(ByVal UserName As String) As cSolicitud

Dim k As Integer


UserName = UCase$(UserName)

For k = 1 To Solicitudes.Count
    If UCase$(Solicitudes(k).UserName) = UserName Then
            Set GetSolicitud = Solicitudes(k)
            Exit Function
    End If
Next k


End Function

Public Function IncludesPeaceOffer(ByVal Name As String) As Boolean

Dim k As Integer

Name = UCase$(Name)

For k = 1 To PeacePropositions.Count
    If UCase$(PeacePropositions(k).UserName) = Name Then
            IncludesPeaceOffer = True
            Exit Function
    End If
Next k



End Function

Public Sub ResetVotes()

Dim k As Integer
For k = 1 To Votes.Count
    Call Votes.Remove(1)
Next k

End Sub


Public Function IsMember(ByVal Name As String) As Boolean

Dim k As Integer

Name = UCase$(Name)

For k = 1 To Members.Count
    If UCase$(Members(k)) = Name Then
            IsMember = True
            Exit Function
    End If
Next k

End Function


Public Function NuevoLider() As String

Dim j As Integer, c As Integer

Dim totals() As tVotes

If Members.Count = 0 Then
    NuevoLider = "CLANCLAUSURADO"
    Exit Function
End If

ReDim totals(1 To Members.Count)


For j = 1 To Members.Count

    totals(j).Name = Members(j)
    totals(j).Cant = 0
    
Next j


For j = 1 To Votes.Count
    
    For c = 1 To Members.Count
        If UCase$(totals(c).Name) = UCase$(Votes(j)) Then
            totals(c).Cant = totals(c).Cant + 1
            Exit For
        End If
    Next c
    
Next j

Dim max As Integer
max = -1

For j = 1 To Members.Count
    If totals(j).Cant > max Then
            max = totals(j).Cant
            NuevoLider = totals(j).Name
    End If
Next j

End Function
