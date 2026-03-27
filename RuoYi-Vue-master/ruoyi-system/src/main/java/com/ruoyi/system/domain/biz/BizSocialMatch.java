package com.ruoyi.system.domain.biz;

import com.ruoyi.common.core.domain.BaseEntity;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;

import java.util.Date;

/**
 * 社交互动对象 biz_social_match
 */
public class BizSocialMatch extends BaseEntity {
    private static final long serialVersionUID = 1L;

    private Long matchId;

    private Long initiatorUserId;

    private Long receiverUserId;

    private Long initiatorPetId;

    private Long receiverPetId;

    private Integer matchScore;

    private String matchedTags;

    private String status;

    private String inviteMessage;

    private String inviteType;

    private Date inviteTime;

    private Date eventTime;

    private String eventLocation;

    private Date responseTime;

    private String initiatorPetName;

    private String receiverPetName;

    private String initiatorUserName;

    private String receiverUserName;

    private Integer friendLinked;

    public Long getMatchId() {
        return matchId;
    }

    public void setMatchId(Long matchId) {
        this.matchId = matchId;
    }

    public Long getInitiatorUserId() {
        return initiatorUserId;
    }

    public void setInitiatorUserId(Long initiatorUserId) {
        this.initiatorUserId = initiatorUserId;
    }

    public Long getReceiverUserId() {
        return receiverUserId;
    }

    public void setReceiverUserId(Long receiverUserId) {
        this.receiverUserId = receiverUserId;
    }

    public Long getInitiatorPetId() {
        return initiatorPetId;
    }

    public void setInitiatorPetId(Long initiatorPetId) {
        this.initiatorPetId = initiatorPetId;
    }

    public Long getReceiverPetId() {
        return receiverPetId;
    }

    public void setReceiverPetId(Long receiverPetId) {
        this.receiverPetId = receiverPetId;
    }

    public Integer getMatchScore() {
        return matchScore;
    }

    public void setMatchScore(Integer matchScore) {
        this.matchScore = matchScore;
    }

    public String getMatchedTags() {
        return matchedTags;
    }

    public void setMatchedTags(String matchedTags) {
        this.matchedTags = matchedTags;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getInviteMessage() {
        return inviteMessage;
    }

    public void setInviteMessage(String inviteMessage) {
        this.inviteMessage = inviteMessage;
    }

    public String getInviteType() {
        return inviteType;
    }

    public void setInviteType(String inviteType) {
        this.inviteType = inviteType;
    }

    public Date getInviteTime() {
        return inviteTime;
    }

    public void setInviteTime(Date inviteTime) {
        this.inviteTime = inviteTime;
    }

    public Date getEventTime() {
        return eventTime;
    }

    public void setEventTime(Date eventTime) {
        this.eventTime = eventTime;
    }

    public String getEventLocation() {
        return eventLocation;
    }

    public void setEventLocation(String eventLocation) {
        this.eventLocation = eventLocation;
    }

    public Date getResponseTime() {
        return responseTime;
    }

    public void setResponseTime(Date responseTime) {
        this.responseTime = responseTime;
    }

    public String getInitiatorPetName() {
        return initiatorPetName;
    }

    public void setInitiatorPetName(String initiatorPetName) {
        this.initiatorPetName = initiatorPetName;
    }

    public String getReceiverPetName() {
        return receiverPetName;
    }

    public void setReceiverPetName(String receiverPetName) {
        this.receiverPetName = receiverPetName;
    }

    public String getInitiatorUserName() {
        return initiatorUserName;
    }

    public void setInitiatorUserName(String initiatorUserName) {
        this.initiatorUserName = initiatorUserName;
    }

    public String getReceiverUserName() {
        return receiverUserName;
    }

    public void setReceiverUserName(String receiverUserName) {
        this.receiverUserName = receiverUserName;
    }

    public Integer getFriendLinked() {
        return friendLinked;
    }

    public void setFriendLinked(Integer friendLinked) {
        this.friendLinked = friendLinked;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("matchId", getMatchId())
                .append("initiatorUserId", getInitiatorUserId())
                .append("receiverUserId", getReceiverUserId())
                .append("initiatorPetId", getInitiatorPetId())
                .append("receiverPetId", getReceiverPetId())
                .append("matchScore", getMatchScore())
                .append("matchedTags", getMatchedTags())
                .append("status", getStatus())
                .append("inviteMessage", getInviteMessage())
                .append("inviteType", getInviteType())
                .append("inviteTime", getInviteTime())
                .append("eventTime", getEventTime())
                .append("eventLocation", getEventLocation())
                .append("responseTime", getResponseTime())
                .append("initiatorPetName", getInitiatorPetName())
                .append("receiverPetName", getReceiverPetName())
                .append("initiatorUserName", getInitiatorUserName())
                .append("receiverUserName", getReceiverUserName())
                .append("friendLinked", getFriendLinked())
                .append("createBy", getCreateBy())
                .append("createTime", getCreateTime())
                .append("updateBy", getUpdateBy())
                .append("updateTime", getUpdateTime())
                .append("remark", getRemark())
                .toString();
    }
}
