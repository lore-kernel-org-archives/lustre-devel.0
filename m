From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Thu, 01 Oct 2009 19:14:29 -0700
Subject: [Lustre-devel] Lustre version number and rpm "Release"
Message-ID: <4AC56205.5060403@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I am in the process of creating our LLNL branch of Lustre which is based
on b1_8.  Our build system for our branch of 1.6.6 was an additional top
level directory of make files, scripts, and our own custom lustre.spec
file.  As part of moving to 1.8, I want to try to get rid of that upper
layer and make the upstream 1.8 code our top level directory.

In bug 16424 there was discussion about setting custom version strings.
 The recommended method seems to be to set the LUSTRE_VERS string.  I
gave this a try, but it doesn't appear to be of much use to us as it stands.

As far as I can tell, setting LUSTRE_VERS will change the "Build
Version:" string that you see on the console upon loading the lustre
modules, and not much else.

Mainly here at LLNL we just want to append our own local version number
extension to Lustre's version number.  If the upstream version is
"1.8.1.50", we want our local build to have the version
"1.8.1.50-3chaos".  LUSTRE_VERS mostly covers this part.

But we also want to prefix the rpm Release string with the same number.

In other words, when we build rpms we get:

$ rpm -qpi lustre-1.8.1.50-2.6.18_70chaos_200910011803.x86_64.rpm
Name        : lustre                       Relocations: (not relocatable)
Version     : 1.8.1.50                          Vendor: (none)
Release     : 2.6.18_70chaos_200910011803   Build Date: Thu Oct  1
18:11:30 2009

And instead we want this:

$ rpm -qpi lustre-1.8.1.50-3chaos_2.6.18_70chaos_200910011803.x86_64.rpm
Name        : lustre                       Relocations: (not relocatable)
Version     : 1.8.1.50                          Vendor: (none)
Release     : 3chaos_2.6.18_70chaos_200910011803   Build Date: Thu Oct
1 18:11:30 2009

Is there current a method for doing that?

Chris
