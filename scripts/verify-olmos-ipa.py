"""Verify the packaged Mach-O slices, rather than trusting only Info.plist."""
import plistlib
import struct
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as archive:
    assert archive.testzip() is None, 'Corrupt ZIP'
    root = 'Payload/OlmosKiosk.app/'
    info = plistlib.loads(archive.read(root + 'Info.plist'))
    assert info['MinimumOSVersion'] == '9.0'
    assert info['CFBundleIdentifier'] == 'com.recowass.olmoskiosk'
    assert info['UIRequiredDeviceCapabilities'] == ['armv7']
    assert info['NSAppTransportSecurity']['NSAllowsArbitraryLoads'] is True
    binary = archive.read(root + info['CFBundleExecutable'])
assert struct.unpack_from('>I', binary)[0] == 0xCAFEBABE, 'Expected universal Mach-O'
count = struct.unpack_from('>I', binary, 4)[0]
assert count == 2
seen = set()
for i in range(count):
    cpu, subtype, offset, size, align = struct.unpack_from('>IIIII', binary, 8 + 20 * i)
    assert cpu in (12, 0x100000C) and cpu not in seen
    seen.add(cpu)
    thin = binary[offset:offset + size]
    assert len(thin) == size
    magic, actual_cpu, _, _, commands = struct.unpack_from('<IIIII', thin)
    assert actual_cpu == cpu
    assert magic == (0xFEEDFACE if cpu == 12 else 0xFEEDFACF)
    pos = 28 if cpu == 12 else 32
    minimum = None
    entry = None
    for _ in range(commands):
        cmd, length = struct.unpack_from('<II', thin, pos)
        assert length >= 8 and pos + length <= len(thin)
        if cmd == 0x25:  # LC_VERSION_MIN_IPHONEOS
            minimum = struct.unpack_from('<I', thin, pos + 8)[0]
        if cmd == 0x80000028:  # LC_MAIN
            entry = struct.unpack_from('<Q', thin, pos + 8)[0]
        pos += length
    assert minimum == 0x90000, f'{cpu}: minimum is not iOS 9.0'
    assert entry is not None
    if cpu == 12:
        assert entry % 2 == 0, 'armv7 ARM-mode entry point must be even'
    print(f'PASS: {"armv7" if cpu == 12 else "arm64"}, minimum iOS 9.0, LC_MAIN {entry}')
print('PASS: IPA integrity and metadata. Unsigned; must be signed before installation.')
