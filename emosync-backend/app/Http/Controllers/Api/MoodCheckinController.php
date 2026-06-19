<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MoodCheckin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MoodCheckinController extends Controller
{
    public function index(Request $request)
    {
        $checkins = $request->user()
            ->moodCheckins()
            ->with(['pemicus' => function($query) {
                $query->select('pemicus.id', 'pemicus.nama');
            }])
            ->orderBy('created_at', 'desc')
            ->limit(30)
            ->get();

        return response()->json($checkins);
    }

    public function store(Request $request)
    {
        $request->validate([
            'mood' => 'required|string|in:happy,anxious,calm,sad',
            'catatan' => 'nullable|string|max:500',
            'pemicu_ids' => 'nullable|array',
            'pemicu_ids.*' => 'exists:pemicus,id',
        ]);

        $user = $request->user();
        
        // Cek apakah sudah check-in hari ini
        $hasCheckedToday = MoodCheckin::where('user_id', $user->id)
            ->whereDate('created_at', today())
            ->exists();
        
        if ($hasCheckedToday) {
            return response()->json([
                'message' => 'Anda sudah melakukan check-in hari ini'
            ], 422);
        }

        DB::beginTransaction();
        
        try {
            $checkin = MoodCheckin::create([
                'user_id' => $user->id,
                'mood' => $request->mood,
                'catatan' => $request->catatan,
            ]);

            if ($request->has('pemicu_ids')) {
                $checkin->pemicus()->attach($request->pemicu_ids);
            }
            
            DB::commit();
            
            return response()->json($checkin->load('pemicus'), 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Gagal menyimpan check-in'], 500);
        }
    }

    public function dashboard(Request $request)
    {
        $user = $request->user();
        
        // Hitung streak
        $streak = $this->calculateStreak($user);
        
        // Ambil weekly checkins (7 hari terakhir)
        $weeklyCheckins = $user->moodCheckins()
            ->where('created_at', '>=', now()->subDays(7))
            ->orderBy('created_at', 'asc')
            ->get(['id', 'mood', 'catatan', 'created_at']);
        
        // Hitung distribusi mood
        $moodDistribution = $user->moodCheckins()
            ->select('mood', DB::raw('count(*) as count'))
            ->groupBy('mood')
            ->pluck('count', 'mood')
            ->toArray();
        
        // Hitung rata-rata mood
        $averageMood = $this->calculateAverageMood($user);
        
        return response()->json([
            'streak' => $streak,
            'rata_rata_mood' => $averageMood,
            'mood_distribution' => $moodDistribution,
            'weekly_checkins' => $weeklyCheckins,
        ]);
    }

    private function calculateStreak($user)
    {
        $checkins = $user->moodCheckins()
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

    private function calculateAverageMood($user)
    {
        $moodValues = [
            'happy' => 4,
            'calm' => 3,
            'anxious' => 2,
            'sad' => 1,
        ];

        $result = DB::table('mood_checkins')
            ->where('user_id', $user->id)
            ->select(DB::raw('AVG(CASE 
                WHEN mood = "happy" THEN 4
                WHEN mood = "calm" THEN 3
                WHEN mood = "anxious" THEN 2
                WHEN mood = "sad" THEN 1
                ELSE 0
            END) as average'))
            ->first();

        return $result->average ? round($result->average, 1) : 0;
    }
}