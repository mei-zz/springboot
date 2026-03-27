import request from '@/utils/request'

export function listContent(query) {
    return request({
        url: '/biz/content/list',
        method: 'get',
        params: query
    })
}

export function addContent(data) {
    return request({
        url: '/biz/content',
        method: 'post',
        data
    })
}

export function listRecommendedContent(query) {
    return request({
        url: '/biz/content/recommend',
        method: 'get',
        params: query
    })
}
