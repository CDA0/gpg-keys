# GPG Key creation

## Generate a primary keypair for an identity

`gpg --expert --full-generate-key`

Select `RSA (set your own capabilities)`.

Toggle `sign` and `encrypt` OFF so the `current allowed actions` is `certify`***.

****Create a key length of 4096 bits.

Provide an expiry date (3y).

Finish creating with name and email.

## Add subkeys

Add shorterlived subkeys for sign, encryption and authenticate.

`gpg --export --edit-key name@example.com`

The prompt will change to `gpg>`.

The `addkey` command is used to create each subkey. Choose the option for `RSA (set your own capabilities)`.

Use a smaller length of 3072 to reduce size of the key.

After all three subkeys are created use the `save` command to exit.

## Add a picture

You can also at this point add a small image tothey key, but I won't cover that.

## Export the secret

`gpg --export-secret-key --armor name@example.com > \<name@example.com\>.private.gpg-key`

## Create a revocation certificate

`gpg --armor --gen-revoke name@example.com > \<name@example.com\>.gpg-revocation-certificate`

## Create qr codes

Use the `./printkey.sh` script to take a key, split it up and create a qrcode for each part.
Print these out and store them safely.

## Test scanned keypair

Run the following command to ensure the crc of the keypair is good.
`gpg --dearmor newkey >/dev/null`

If the key is already exported we can diff the files:

`diff input <name@example.com>`

## Remove the primary key

Check the output of `gpg --list-secret-keys`

```
gpg --export-secret-subkeys --armor name@example.com > \<name@example.com\>.subkeys.gpg-key
gpg --delete-secret-keys name@example.com
gpg --import \<name@example.com\>.subkeys.gpg-key
```

Now look at the output of `gpg --list-secret-keys` it should say `#sec` in the first key.
This means that the signing key is not in the keypair.

Now `shred -z -u $file` any exported files.

## Move to another system

`gpg --export-secret-keys --armor name@example.com > \<name@example.com\>.laptop.private.gpg-key`
`gpg --export --armor name@example.com > \<name@example.com\>.laptop.public.gpg-key`

Then on the new system

`gpg --import \<name@example.com\>.laptop.public.gpg-key`
`gpg --import \<name@example.com\>.laptop.private.gpg-key`

## Restoring

Scan each barcode into a file:

`zbarcam --raw >> inputkey`

verify the CRC with

`gpg --dearmor inputkey >/dev/null`

After scanning there might be a 0x0A missing at the end of line 1 and an extra 0x0A at the end of
the last line.

Importing to an offline RPI running raspian involves using the loopback pinentry command

`gpg --import --pinentry-mode loopback inputkey`

## Expiring keys

When a key is expiring

`gpg --expert --edit-key <key>`

`key 1`

`expire`

## SSH Keys

To export ssh public key

`gpg --export-ssh-key name@email.com`

and the privatekey

`gpg --export-ssh-secret-key name@email.com`

## Resources

* https://alexcabal.com/creating-the-perfect-gpg-keypair
* https://spin.atomicobject.com/2013/11/24/secure-gpg-keys-guide/
* https://unix.stackexchange.com/questions/280222/generating-qr-code-of-very-big-file
* http://wiki.debian.org/subkeys
* https://security.stackexchange.com/questions/31594/what-is-a-good-general-purpose-gnupg-key-setup
