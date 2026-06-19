<?php

namespace Database\Seeders;

use App\Models\Subscription;
use App\Models\User;
use Illuminate\Database\Seeder;

class SubscriptionSeeder extends Seeder
{
    public function run(): void
    {
        // Beri premium untuk user pertama (Demas Axel)
        $user = User::where('username', 'demasaxel')->first();
        if ($user) {
            Subscription::create([
                'user_id' => $user->id,
                'plan' => 'premium_monthly',
                'start_date' => now(),
                'end_date' => now()->addDays(30),
                'status' => 'active',
                'payment_method' => 'demo',
                'transaction_id' => 'DEMO_' . time(),
            ]);
            $user->activatePremium(30);
        }
    }
}