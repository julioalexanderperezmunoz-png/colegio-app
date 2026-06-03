<?php

namespace App\Http\Controllers\Api;

use App\Models\Grado;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class GradoController extends Controller
{
    public function index()
    {
        return Grado::all();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nombre' => 'required|string|max:255',
            'nivel'  => 'required|string|max:255',
        ]);
        return Grado::create($data);
    }

    public function show(Grado $grado)
    {
        return $grado;
    }

    public function update(Request $request, Grado $grado)
    {
        $data = $request->validate([
            'nombre' => 'required|string|max:255',
            'nivel'  => 'required|string|max:255',
        ]);
        $grado->update($data);
        return $grado;
    }

    public function destroy(Grado $grado)
    {
        $grado->delete();
        return response()->noContent();
    }
}