<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pemicu;

class PemicuController extends Controller
{
    public function index()
    {
        $pemicus = Pemicu::all();
        return response()->json($pemicus);
    }
}