package com.ruoyi.system.domain.biz;

import com.ruoyi.common.core.domain.BaseEntity;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;

import java.math.BigDecimal;
import java.util.Date;

/**
 * 宠物档案对象 biz_pet_info
 */
public class BizPetInfo extends BaseEntity {
    private static final long serialVersionUID = 1L;

    private Long petId;

    private Long ownerUserId;

    private String petName;

    private String petGender;

    private String breed;

    private Date birthday;

    private Integer ageMonth;

    private BigDecimal weightKg;

    private String avatarUrl;

    private String socialTags;

    private String healthNote;

    private String status;

    /** 扩展字段：匹配度（0-100） */
    private Integer matchScore;

    /** 扩展字段：命中标签 */
    private String matchedTags;

    public Long getPetId() {
        return petId;
    }

    public void setPetId(Long petId) {
        this.petId = petId;
    }

    public Long getOwnerUserId() {
        return ownerUserId;
    }

    public void setOwnerUserId(Long ownerUserId) {
        this.ownerUserId = ownerUserId;
    }

    public String getPetName() {
        return petName;
    }

    public void setPetName(String petName) {
        this.petName = petName;
    }

    public String getPetGender() {
        return petGender;
    }

    public void setPetGender(String petGender) {
        this.petGender = petGender;
    }

    public String getBreed() {
        return breed;
    }

    public void setBreed(String breed) {
        this.breed = breed;
    }

    public Date getBirthday() {
        return birthday;
    }

    public void setBirthday(Date birthday) {
        this.birthday = birthday;
    }

    public Integer getAgeMonth() {
        return ageMonth;
    }

    public void setAgeMonth(Integer ageMonth) {
        this.ageMonth = ageMonth;
    }

    public BigDecimal getWeightKg() {
        return weightKg;
    }

    public void setWeightKg(BigDecimal weightKg) {
        this.weightKg = weightKg;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getSocialTags() {
        return socialTags;
    }

    public void setSocialTags(String socialTags) {
        this.socialTags = socialTags;
    }

    public String getHealthNote() {
        return healthNote;
    }

    public void setHealthNote(String healthNote) {
        this.healthNote = healthNote;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("petId", getPetId())
                .append("ownerUserId", getOwnerUserId())
                .append("petName", getPetName())
                .append("petGender", getPetGender())
                .append("breed", getBreed())
                .append("birthday", getBirthday())
                .append("ageMonth", getAgeMonth())
                .append("weightKg", getWeightKg())
                .append("avatarUrl", getAvatarUrl())
                .append("socialTags", getSocialTags())
                .append("healthNote", getHealthNote())
                .append("status", getStatus())
                .append("matchScore", getMatchScore())
                .append("matchedTags", getMatchedTags())
                .append("createBy", getCreateBy())
                .append("createTime", getCreateTime())
                .append("updateBy", getUpdateBy())
                .append("updateTime", getUpdateTime())
                .append("remark", getRemark())
                .toString();
    }
}
