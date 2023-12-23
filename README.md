```bash
cd external/raylib
cmake -B build -DBUILD_EXAMPLES=false && cmake --build build -j $(nproc)
```
