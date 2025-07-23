# boj-10813.py

N, M = map(int, input().split())
# print(N, M)

basket = [i for i in range(1, N+1)]


for _ in range(M):
    i, j = map(int, input().split())
    i -= 1
    j -= 1
    basket[i], basket[j] = basket[j], basket[i]

print(*basket) # *를 붙여주면 언패킹이라고 해서 띄어쓰기만으로 프린트 해줌
