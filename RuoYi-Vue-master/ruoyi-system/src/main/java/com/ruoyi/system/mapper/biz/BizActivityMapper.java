package com.ruoyi.system.mapper.biz;

import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 社区活动数据层
 */
public interface BizActivityMapper {
    List<Map<String, Object>> selectActivityList(@Param("reviewStatus") String reviewStatus,
            @Param("creatorUserId") Long creatorUserId);

    int insertActivity(Map<String, Object> activity);

    int updateActivityReview(@Param("activityId") Long activityId,
            @Param("reviewStatus") String reviewStatus,
            @Param("reviewNote") String reviewNote,
            @Param("reviewBy") String reviewBy);

    Map<String, Object> selectActivityById(@Param("activityId") Long activityId);

    int countSignup(@Param("activityId") Long activityId, @Param("userId") Long userId, @Param("petId") Long petId);

    int insertSignup(@Param("activityId") Long activityId,
            @Param("userId") Long userId,
            @Param("petId") Long petId,
            @Param("createBy") String createBy,
            @Param("updateBy") String updateBy);

    int increaseParticipants(@Param("activityId") Long activityId);

    List<Map<String, Object>> selectMySignupList(@Param("userId") Long userId);
}
