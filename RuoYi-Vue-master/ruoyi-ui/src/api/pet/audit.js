import request from '@/utils/request'

export function listAuditContent(query) {
    return request({
        url: '/biz/audit/content/list',
        method: 'get',
        params: query
    })
}

export function reviewContent(contentId, data) {
    return request({
        url: '/biz/audit/content/' + contentId,
        method: 'put',
        data
    })
}

export function listAuditActivity(query) {
    return request({
        url: '/biz/audit/activity/list',
        method: 'get',
        params: query
    })
}

export function reviewActivity(activityId, data) {
    return request({
        url: '/biz/audit/activity/' + activityId,
        method: 'put',
        data
    })
}
