--!nocheck

local UserInfo = {}

function UserInfo.init(ctx)
    local userInfo    = ctx.userInfo
    local LocalPlayer = ctx.LocalPlayer
    local Format      = ctx.Format
    local myRank      = ctx.Ranks.myRank

    userInfo.DisplayNameLabel.Text  = LocalPlayer.DisplayName
    userInfo.UserNameLabel.Text     = "@" .. LocalPlayer.Name
    userInfo.RankTextLabel.RichText = true
    userInfo.RankTextLabel.Text     = Format.fmtRankTag(myRank)
    userInfo.UserFrame.UserImageLabel.Image =
        "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
end

return UserInfo
