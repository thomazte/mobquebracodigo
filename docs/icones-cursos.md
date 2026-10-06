# Ícones dos cursos

Os ícones em `assets/cursos/` são gerados a partir das artes originais em `scripts/source/cursos/`, que vêm em tamanhos e margens diferentes (1024 × 1024 e 1024 × 1536).

```bash
python3 scripts/build-course-icons.py
```

O script recorta cada logo pelo que é visível e a centraliza num PNG quadrado e transparente de 512 px. A escala iguala a área ocupada, e não o lado maior, para logos largas (PHP) ou altas (Java, SQL) terem o mesmo peso visual das quadradas; nenhum lado passa de 92% do quadro.

Para trocar ou adicionar um curso, coloque a arte em `scripts/source/cursos/` com o nome usado em `lib/models/course_model.dart` e rode o script. As telas mostram os ícones com `BoxFit.contain`, então não há corte.
