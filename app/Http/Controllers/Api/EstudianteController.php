<?php

namespace App\Http\Controllers\Api;

use App\Models\Estudiante;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Storage;

class EstudianteController extends Controller
{
    public function index()
    {
        return Estudiante::with('grado')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'grado_id' => 'required|exists:grados,id',
            'nombres'  => 'required|string|max:255',
            'dni'      => 'required|string|unique:estudiantes',
            'foto'     => 'nullable|image|max:2048',
        ]);

        if ($request->hasFile('foto')) {
            $path = $request->file('foto')->store('estudiantes', 'public');
            $data['foto'] = $path;
        }

        return Estudiante::create($data);
    }

    public function update(Request $request, Estudiante $estudiante)
    {
        $data = $request->validate([
            'grado_id' => 'required|exists:grados,id',
            'nombres'  => 'required|string|max:255',
            'dni'      => 'required|string|unique:estudiantes,dni,' . $estudiante->id,
            'foto'     => 'nullable|image|max:2048',
        ]);

        if ($request->hasFile('foto')) {
            if ($estudiante->foto) {
                Storage::disk('public')->delete($estudiante->foto);
            }
            $path = $request->file('foto')->store('estudiantes', 'public');
            $data['foto'] = $path;
        }

        $estudiante->update($data);
        return $estudiante;
    }

    public function destroy(Estudiante $estudiante)
    {
        if ($estudiante->foto) {
            Storage::disk('public')->delete($estudiante->foto);
        }
        $estudiante->delete();
        return response()->noContent();
    }
}