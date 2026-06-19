<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    /**
     * Get all user settings
     * 
     * GET /api/settings
     */
    public function index(Request $request)
    {
        $settings = $request->user()->getSettings();
        
        return response()->json([
            'notification' => [
                'daily_reminder' => $settings->notif_daily_reminder,
                'weekly_report' => $settings->notif_weekly_report,
                'friend_activity' => $settings->notif_friend_activity,
                'tips_insights' => $settings->notif_tips_insights,
            ],
            'privacy' => [
                'show_mood' => $settings->privacy_show_mood,
                'allow_requests' => $settings->privacy_allow_requests,
                'show_active' => $settings->privacy_show_active,
            ],
        ]);
    }

    /**
     * Update notification settings
     * 
     * PUT /api/settings/notification
     */
    public function updateNotification(Request $request)
    {
        $request->validate([
            'daily_reminder' => 'sometimes|boolean',
            'weekly_report' => 'sometimes|boolean',
            'friend_activity' => 'sometimes|boolean',
            'tips_insights' => 'sometimes|boolean',
        ]);

        $settings = $request->user()->getSettings();
        
        if ($request->has('daily_reminder')) {
            $settings->notif_daily_reminder = $request->daily_reminder;
        }
        if ($request->has('weekly_report')) {
            $settings->notif_weekly_report = $request->weekly_report;
        }
        if ($request->has('friend_activity')) {
            $settings->notif_friend_activity = $request->friend_activity;
        }
        if ($request->has('tips_insights')) {
            $settings->notif_tips_insights = $request->tips_insights;
        }
        
        $settings->save();
        
        return response()->json([
            'message' => 'Notification settings updated successfully',
            'data' => [
                'daily_reminder' => $settings->notif_daily_reminder,
                'weekly_report' => $settings->notif_weekly_report,
                'friend_activity' => $settings->notif_friend_activity,
                'tips_insights' => $settings->notif_tips_insights,
            ]
        ]);
    }

    /**
     * Update privacy settings
     * 
     * PUT /api/settings/privacy
     */
    public function updatePrivacy(Request $request)
    {
        $request->validate([
            'show_mood' => 'sometimes|boolean',
            'allow_requests' => 'sometimes|boolean',
            'show_active' => 'sometimes|boolean',
        ]);

        $settings = $request->user()->getSettings();
        
        if ($request->has('show_mood')) {
            $settings->privacy_show_mood = $request->show_mood;
        }
        if ($request->has('allow_requests')) {
            $settings->privacy_allow_requests = $request->allow_requests;
        }
        if ($request->has('show_active')) {
            $settings->privacy_show_active = $request->show_active;
        }
        
        $settings->save();
        
        return response()->json([
            'message' => 'Privacy settings updated successfully',
            'data' => [
                'show_mood' => $settings->privacy_show_mood,
                'allow_requests' => $settings->privacy_allow_requests,
                'show_active' => $settings->privacy_show_active,
            ]
        ]);
    }
}