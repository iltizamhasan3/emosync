<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Support\Facades\DB;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
        'is_premium',
        'premium_plan',
        'premium_expiry',
        'avatar',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'premium_expiry' => 'datetime',
        'is_premium' => 'boolean',
    ];

    // ============ CHAT RELATIONSHIPS ============

    public function sentMessages()
    {
    return $this->hasMany(Chat::class, 'sender_id');
    }

    public function receivedMessages()
    {
    return $this->hasMany(Chat::class, 'receiver_id');
    }

    // ============ RELATIONSHIPS ============
    public function moodCheckins()
    {
        return $this->hasMany(MoodCheckin::class);
    }

    public function friendships()
    {
        return $this->hasMany(Friendship::class, 'user_id');
    }

    public function friends()
    {
        return $this->belongsToMany(User::class, 'friendships', 'user_id', 'friend_id')
            ->wherePivot('status', 'accepted')
            ->withPivot('status', 'created_at');
    }

    public function friendRequests()
    {
        return $this->belongsToMany(User::class, 'friendships', 'friend_id', 'user_id')
            ->wherePivot('status', 'pending')
            ->withPivot('id', 'created_at');
    }

    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }

    public function activeSubscription()
    {
        return $this->hasOne(Subscription::class)->where('status', 'active')->latest();
    }

    public function settings()
    {
        return $this->hasOne(UserSetting::class);
    }

    // ============ METHODS ============
    
    /**
     * Check if user is premium and subscription is still valid
     */
    public function isPremium()
    {
        // Cek is_premium dan premium_expiry
        if ($this->is_premium && $this->premium_expiry) {
            return $this->premium_expiry->isFuture();
        }
        return false;
    }

    /**
     * Calculate user's streak
     */
    public function getStreakAttribute()
    {
        $checkins = $this->moodCheckins()
            ->orderBy('created_at', 'desc')
            ->get(['created_at']);
        
        if ($checkins->isEmpty()) {
            return 0;
        }
        
        $streak = 0;
        $lastDate = null;
        
        foreach ($checkins as $checkin) {
            $currentDate = $checkin->created_at->toDateString();
            
            if ($lastDate === null) {
                $streak = 1;
                $lastDate = $currentDate;
            } else {
                $diff = date_diff(
                    date_create($currentDate),
                    date_create($lastDate)
                )->days;
                
                if ($diff == 1) {
                    $streak++;
                    $lastDate = $currentDate;
                } elseif ($diff == 0) {
                    continue;
                } else {
                    break;
                }
            }
        }
        
        return $streak;
    }

    /**
     * Get user settings
     */
    public function getSettings()
    {
        if (!$this->settings) {
            $this->settings()->create([]);
            $this->load('settings');
        }
        return $this->settings;
    }
}