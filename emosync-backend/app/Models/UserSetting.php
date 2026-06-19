<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserSetting extends Model
{
    use HasFactory;

    protected $table = 'user_settings';

    protected $fillable = [
        'user_id',
        'notif_daily_reminder',
        'notif_weekly_report',
        'notif_friend_activity',
        'notif_tips_insights',
        'privacy_show_mood',
        'privacy_allow_requests',
        'privacy_show_active',
    ];

    protected $casts = [
        'notif_daily_reminder' => 'boolean',
        'notif_weekly_report' => 'boolean',
        'notif_friend_activity' => 'boolean',
        'notif_tips_insights' => 'boolean',
        'privacy_show_mood' => 'boolean',
        'privacy_allow_requests' => 'boolean',
        'privacy_show_active' => 'boolean',
    ];

    /**
     * Get the user that owns the settings.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}