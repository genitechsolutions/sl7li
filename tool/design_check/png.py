import zlib, struct, sys
def load(path):
    d = open(path,'rb').read()
    assert d[:8] == b'\x89PNG\r\n\x1a\n'
    i = 8; idat = b''
    while i < len(d):
        n = struct.unpack('>I', d[i:i+4])[0]; t = d[i+4:i+8]; c = d[i+8:i+8+n]; i += 12+n
        if t == b'IHDR': w,h,bd,ct,_,_,il = struct.unpack('>IIBBBBB', c)
        elif t == b'IDAT': idat += c
    assert bd == 8 and il == 0, (bd, il)
    bpp = {6:4, 2:3, 0:1, 4:2}[ct]
    raw = zlib.decompress(idat); stride = w*bpp; rows = []; prev = bytearray(stride); p = 0
    for y in range(h):
        f = raw[p]; line = bytearray(raw[p+1:p+1+stride]); p += 1+stride
        for x in range(stride):
            a = line[x-bpp] if x >= bpp else 0; b = prev[x]; c = prev[x-bpp] if x >= bpp else 0
            if f == 1: line[x] = (line[x]+a) & 255
            elif f == 2: line[x] = (line[x]+b) & 255
            elif f == 3: line[x] = (line[x]+((a+b)>>1)) & 255
            elif f == 4:
                pa, pb, pc = abs(b-c), abs(a-c), abs(a+b-2*c)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                line[x] = (line[x]+pr) & 255
        rows.append(bytes(line)); prev = line
    def px(x, y):
        r = rows[y][x*bpp:(x+1)*bpp]
        return tuple(r)
    return w, h, px
