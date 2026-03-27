import request from '@/utils/request'

// 查询宠物档案列表
export function listPetInfo(query) {
    return request({ url: '/biz/pet/list', method: 'get', params: query })
}

// 查询宠物档案详细
export function getPetInfo(petId) {
    return request({ url: '/biz/pet/' + petId, method: 'get' })
}

// 新增宠物档案
export function addPetInfo(data) {
    return request({ url: '/biz/pet', method: 'post', data: data })
}

// 修改宠物档案
export function updatePetInfo(data) {
    return request({ url: '/biz/pet', method: 'put', data: data })
}

// 删除宠物档案
export function delPetInfo(petId) {
    return request({ url: '/biz/pet/' + petId, method: 'delete' })
}
