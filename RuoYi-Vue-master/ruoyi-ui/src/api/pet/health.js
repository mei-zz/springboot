import request from '@/utils/request'

// 查询健康记录列表
export function listHealthRecord(query) {
    return request({ url: '/biz/health/list', method: 'get', params: query })
}

// 新增健康记录
export function addHealthRecord(data) {
    return request({ url: '/biz/health/record', method: 'post', data: data })
}

// 删除健康记录
export function delHealthRecord(recordId) {
    return request({ url: '/biz/health/' + recordId, method: 'delete' })
}
