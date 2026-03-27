import request from '@/utils/request'

// 获取社交推荐列表
export function getSocialMatchList(currentPetId) {
    return request({
        url: '/biz/social/match/' + currentPetId,
        method: 'get'
    })
}

// 发送社交邀请
export function sendSocialInvite(data) {
    return request({
        url: '/biz/social/invite',
        method: 'post',
        data: data
    })
}

// 查询当前账号社交历史
export function listSocialHistory(query) {
    return request({
        url: '/biz/social/history',
        method: 'get',
        params: query
    })
}

// 接受/拒绝社交邀请
export function respondSocialInvite(matchId, data) {
    return request({
        url: '/biz/social/respond/' + matchId,
        method: 'put',
        data: data
    })
}

// 根据成功互动添加好友
export function addSocialFriend(matchId) {
    return request({
        url: '/biz/social/friend/' + matchId,
        method: 'post'
    })
}

// 查询好友列表
export function listSocialFriends(query) {
    return request({
        url: '/biz/social/friends',
        method: 'get',
        params: query
    })
}

// 查询社交统计
export function getSocialStats() {
    return request({
        url: '/biz/social/stats',
        method: 'get'
    })
}

// 查询活跃排行
export function listSocialRank(query) {
    return request({
        url: '/biz/social/rank',
        method: 'get',
        params: query
    })
}
