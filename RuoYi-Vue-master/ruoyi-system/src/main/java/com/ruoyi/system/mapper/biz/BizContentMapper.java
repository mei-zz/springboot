package com.ruoyi.system.mapper.biz;

import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 内容发布与推送数据层
 */
public interface BizContentMapper {
    List<Map<String, Object>> selectContentList(@Param("status") String status,
            @Param("creatorUserId") Long creatorUserId,
            @Param("reviewStatus") String reviewStatus);

    int insertContent(Map<String, Object> content);

    int updateContentReview(@Param("contentId") Long contentId,
            @Param("reviewStatus") String reviewStatus,
            @Param("reviewNote") String reviewNote,
            @Param("reviewBy") String reviewBy);

    List<Map<String, Object>> selectRecommendedContentByUserId(@Param("userId") Long userId);
}
