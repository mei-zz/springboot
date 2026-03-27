import request from '@/utils/request'

// 查询健康预警列表
export function listHealthAlert(query) {
    return request({ url: '/biz/alert/list', method: 'get', params: query })
}

// 标记预警已处理
export function processAlert(alertId, data) {
    return request({ url: '/biz/alert/process/' + alertId, method: 'put', data: data })
}
