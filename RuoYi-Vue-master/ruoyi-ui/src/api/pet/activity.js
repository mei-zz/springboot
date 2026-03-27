import request from '@/utils/request'

export function listActivity(query) {
    return request({
        url: '/biz/activity/list',
        method: 'get',
        params: query
    })
}

export function addActivity(data) {
    return request({
        url: '/biz/activity',
        method: 'post',
        data
    })
}

export function signupActivity(activityId, data) {
    return request({
        url: '/biz/activity/signup/' + activityId,
        method: 'post',
        data
    })
}

export function listMySignups(query) {
    return request({
        url: '/biz/activity/signup/my',
        method: 'get',
        params: query
    })
}
