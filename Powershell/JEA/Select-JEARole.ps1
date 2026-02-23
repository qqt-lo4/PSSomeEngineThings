function Select-JEARole {
    <#
    .SYNOPSIS
        Prompts user to select a JEA role

    .DESCRIPTION
        Retrieves available JEA roles from user's group memberships and prompts for selection.
        Includes option to choose no specific role (admin role).

    .PARAMETER Credential
        Credentials to use when retrieving available roles.

    .PARAMETER GroupNameTemplate
        Template pattern for JEA group names (includes script name by default).

    .PARAMETER GroupMatchIndex
        Index of regex match group to extract role name from (-1 for last match).

    .OUTPUTS
        [Object]. Selected role information with AnswerType and Value properties.

    .EXAMPLE
        Select-JEARole -Credential $cred

    .NOTES
        Author  : Loïc Ade
        Version : 1.0.0
    #>
    Param(
        [pscredential]$Credential,
        [string]$GroupNameTemplate = ("^(.+)\\ps_jea_(" + (Get-RootScriptName) + ".+)$"),
        [int]$GroupMatchIndex = -1
    )
    $aRoles = Get-JEARoleFromUserGroups -Credential $Credential -Filter $GroupNameTemplate -ResultPatternIndex $GroupMatchIndex
    if ($aRoles) {
        $aItems = @()
        $aNewItems = $aRoles | ForEach-Object { New-Object -TypeName psobject -Property @{AnswerType = "Role"; Name = $_ ; Value = $_ } }
        $aItems += $aNewItems
        $aItems += New-Object -TypeName psobject -Property @{AnswerType = "NoSpecificRoleChosen"; Name = "No specific role / admin role" ; Value = "" }
        return (Get-ItemSelectedByUser $aItems -selectedColumn "Name" -selectHeaderMessage "Which JEA role do you want to use?").Value
    } else {
        return New-Object -TypeName psobject -Property @{AnswerType = "NoSpecificRoleExists"; Name = "No specific role / admin role" ; Value = "" }
    }
}