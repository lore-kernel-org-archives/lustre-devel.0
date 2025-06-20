Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E4398C7115B
	for <lustre-devel@archiver.kernel.org>; Fri, 20 Jun 2025 19:57:38 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4bP7YS1WHYz1xJY;
	Fri, 20 Jun 2025 12:57:32 -0700 (PDT)
Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com
 [209.85.128.52])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4bP7YN45wTz1wdt
 for <lustre-devel@lists.lustre.org>; Fri, 20 Jun 2025 12:57:28 -0700 (PDT)
Received: by mail-wm1-f52.google.com with SMTP id
 5b1f17b1804b1-450ddb35583so3114455e9.1
 for <lustre-devel@lists.lustre.org>; Fri, 20 Jun 2025 12:57:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1750449443; x=1751054243; darn=lists.lustre.org;
 h=content-transfer-encoding:mime-version:message-id:date:subject:cc
 :to:from:from:to:cc:subject:date:message-id:reply-to;
 bh=x/SQDw/KBO4HrN9kzSde+fCUA6otibnDvhPWQWaHDcs=;
 b=CB4piRK8RauHUqUuksix6PgbdEyHzITQu+KjUt6FHh7lOotI7qXP7It236GrgcFXv6
 wK2iQcWgLogU7syy9K2Vk3Xwx2JHjBr9/mzILWLZ2rnUI/fvaKuF+WAy1fcwS59gRt2+
 rkIBs4N/bjOCjQ6OUbJRcWs3h269a7uSXMsMoCryAyeCVSUMVh0VIesFrIuaLHV0C7C1
 fLcYU6UlcoqN3+GCTwmujI7+GWG1Qiku4zQRGhQvhM1JBpdg3ZnveJd8J71JAQb/ZBoR
 36OFewFcKxf2ums4G1eM0C/mNTIJ8HjA09jtdKRNqhPXxEBruTv8JS+xH1Z2mRLeZsCs
 Ci/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1750449444; x=1751054244;
 h=content-transfer-encoding:mime-version:message-id:date:subject:cc
 :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=x/SQDw/KBO4HrN9kzSde+fCUA6otibnDvhPWQWaHDcs=;
 b=m0rnZiWRt0Ed2dW4d0iP3wU2vi/DvzFELgs6LJvpF3ohuFZ0BBDE5yCdv/CQF6BXjG
 4gyQvQPdGSZEZ1WZt7406JHxf6WSdRJUEzrGoKA/uc7oDLMIBuaX95i+VzhUyjW5TjHD
 BX3YbwMzHtdPHe50MTehZ98kPFKroXc34Hobxcg+F/ONZwKLsHfkqXtVB/sZfgU6DE0C
 EFaw6nBvxdjqZQBlkK77XoDs3Rsig8mi3OZOAjmrVp8t/nAvpJLXPGYJAboLros5TaAt
 c8Zfc9jJZ5w6eeP+zET2SGZpPQe49qPKKTonIv+ox280WNh42p+0nV8viAv3qgNNXQrH
 x3WA==
X-Forwarded-Encrypted: i=1;
 AJvYcCXSTHuCScpwdphGpa0qm5ezTTmpHiBpTj+V+ayGHvaJpopuIjTqhjuqqKMlqXRiOfhy1RGdm+9EUIqHqFU=@lists.lustre.org
X-Gm-Message-State: AOJu0Yzb33YMvFkcxp34LtoddVPL/NYonqtIIGG7M3Nz3r2fxZTtHUhZ
 SUjGY1X45vwRPxLeBleyseS0NDVy5YiDTBNEJNldBHEKVjXzWr8SEys=
X-Gm-Gg: ASbGnctOz0UPJBQzxySTiB5Bfde3dAxMWPyYjS+eEFuyzGv9I8ldMpjq1DxCGV+8ajq
 t6lhbCe23QHRr+lsXewTLoGIOdmXOaBD/ih7CmCJtYsGos4ZcXG3O9DJb3vU4aJ7QCm3bBYm9ag
 VbAa3OhfEcBThfgfO+gBT8dBONqS5tTC9p06ecS0uK2TwwOfhIDKrrizOi5LMoVQ0SromCalezn
 701Doj1cRrFPyehWnG65wNf0W1SNIJ89hBgAIN6lK+x1AtFQJB87qSkWVigHDB29paCIfIdrDnX
 8ccDx58+qWOq3YV2vYSk68smvWFL2RBsyzJtFctcGwjUkfcDui+gj0qoeLpVBdWhKybsIExmpxg
 YAzlgIJ2QC3OqUPozAu5s9zUxUg==
X-Google-Smtp-Source: AGHT+IHIoTOTq+ymwQQacjUjitN+QyLuBBlA7Czj9aPrmg71r8ub5nHt4IiMkjGpROXH9jhRdnveVw==
X-Received: by 2002:a05:6000:24c8:b0:3a4:e193:e6e7 with SMTP id
 ffacd0b85a97d-3a6d12e995amr1258307f8f.5.1750449442450; 
 Fri, 20 Jun 2025 12:57:22 -0700 (PDT)
Received: from localhost (220.red-80-39-44.staticip.rima-tde.net.
 [80.39.44.220]) by smtp.gmail.com with ESMTPSA id
 ffacd0b85a97d-3a6d117c068sm2925613f8f.54.2025.06.20.12.57.21
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 20 Jun 2025 12:57:21 -0700 (PDT)
From: Xose Vazquez Perez <xose.vazquez@gmail.com>
To: 
Cc: Xose Vazquez Perez <xose.vazquez@gmail.com>,
 LUSTRE DEVEL ML <lustre-devel@lists.lustre.org>
Date: Fri, 20 Jun 2025 21:57:18 +0200
Message-ID: <20250620195720.59870-1-xose.vazquez@gmail.com>
X-Mailer: git-send-email 2.49.0
MIME-Version: 1.0
X-Patchwork-Bot: notify
Subject: [lustre-devel] [PATCH 1/2] lustre: refresh FSF licences
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Old licences have been modified, because FSF postal address was changed:
https://lists.gnu.org/archive/html/info-gnu/2024-09/msg00000.html
https://www.fsf.org/blogs/community/fsf-office-closing-party

Just "cut and paste" from original sources:
https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt
https://www.gnu.org/licenses/old-licenses/fdl-1.1.tx

Relevant change: postal address was replaced with an URL.

There are may changes in the LGPL-2.1 text, because the original
in the source was not well formatted.

Cc: LUSTRE DEVEL ML <lustre-devel@lists.lustre.org>
Signed-off-by: Xose Vazquez Perez <xose.vazquez@gmail.com>
---
 LICENSES/preferred/GPL-2.0  |  42 +-
 LICENSES/preferred/LGPL-2.1 | 818 ++++++++++++++++++------------------
 debian/copyright            |   8 +-
 lustre/utils/LCOPYING       |   5 +-
 4 files changed, 441 insertions(+), 432 deletions(-)

diff --git a/LICENSES/preferred/GPL-2.0 b/LICENSES/preferred/GPL-2.0
index ff0812fd89..9829bf39a7 100644
--- a/LICENSES/preferred/GPL-2.0
+++ b/LICENSES/preferred/GPL-2.0
@@ -17,15 +17,15 @@ Usage-Guide:
     SPDX-License-Identifier: GPL-2.0-or-later
 License-Text:
 
-		    GNU GENERAL PUBLIC LICENSE
-		       Version 2, June 1991
+                    GNU GENERAL PUBLIC LICENSE
+                       Version 2, June 1991
 
- Copyright (C) 1989, 1991 Free Software Foundation, Inc.
-                       51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ Copyright (C) 1989, 1991 Free Software Foundation, Inc.,
+ <https://fsf.org/>
  Everyone is permitted to copy and distribute verbatim copies
  of this license document, but changing it is not allowed.
 
-			    Preamble
+                            Preamble
 
   The licenses for most software are designed to take away your
 freedom to share and change it.  By contrast, the GNU General Public
@@ -34,7 +34,7 @@ software--to make sure the software is free for all its users.  This
 General Public License applies to most of the Free Software
 Foundation's software and to any other program whose authors commit to
 using it.  (Some other Free Software Foundation software is covered by
-the GNU Library General Public License instead.)  You can apply it to
+the GNU Lesser General Public License instead.)  You can apply it to
 your programs, too.
 
   When we speak of free software, we are referring to freedom, not
@@ -74,8 +74,8 @@ patent must be licensed for everyone's free use or not licensed at all.
 
   The precise terms and conditions for copying, distribution and
 modification follow.
-
-		    GNU GENERAL PUBLIC LICENSE
+
+                    GNU GENERAL PUBLIC LICENSE
    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 
   0. This License applies to any program or other work which contains
@@ -129,7 +129,7 @@ above, provided that you also meet all of these conditions:
     License.  (Exception: if the Program itself is interactive but
     does not normally print such an announcement, your work based on
     the Program is not required to print an announcement.)
-
+
 These requirements apply to the modified work as a whole.  If
 identifiable sections of that work are not derived from the Program,
 and can be reasonably considered independent and separate works in
@@ -187,7 +187,7 @@ access to copy from a designated place, then offering equivalent
 access to copy the source code from the same place counts as
 distribution of the source code, even though third parties are not
 compelled to copy the source along with the object code.
-
+
   4. You may not copy, modify, sublicense, or distribute the Program
 except as expressly provided under this License.  Any attempt
 otherwise to copy, modify, sublicense or distribute the Program is
@@ -244,7 +244,7 @@ impose that choice.
 
 This section is intended to make thoroughly clear what is believed to
 be a consequence of the rest of this License.
-
+
   8. If the distribution and/or use of the Program is restricted in
 certain countries either by patents or by copyrighted interfaces, the
 original copyright holder who places the Program under this License
@@ -274,7 +274,7 @@ make exceptions for this.  Our decision will be guided by the two goals
 of preserving the free status of all derivatives of our free software and
 of promoting the sharing and reuse of software generally.
 
-			    NO WARRANTY
+                            NO WARRANTY
 
   11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
 FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
@@ -296,9 +296,9 @@ YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
 PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGES.
 
-		     END OF TERMS AND CONDITIONS
-
-	    How to Apply These Terms to Your New Programs
+                     END OF TERMS AND CONDITIONS
+
+            How to Apply These Terms to Your New Programs
 
   If you develop a new program, and you want it to be of the greatest
 possible use to the public, the best way to achieve this is to make it
@@ -322,10 +322,8 @@ the "copyright" line and a pointer to where the full notice is found.
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.
 
-    You should have received a copy of the GNU General Public License
-    along with this program; if not, write to the Free Software
-    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-
+    You should have received a copy of the GNU General Public License along
+    with this program; if not, see <https://www.gnu.org/licenses/>.
 
 Also add information on how to contact you by electronic and paper mail.
 
@@ -349,11 +347,11 @@ necessary.  Here is a sample; alter the names:
   Yoyodyne, Inc., hereby disclaims all copyright interest in the program
   `Gnomovision' (which makes passes at compilers) written by James Hacker.
 
-  <signature of Ty Coon>, 1 April 1989
-  Ty Coon, President of Vice
+  <signature of Moe Ghoul>, 1 April 1989
+  Moe Ghoul, President of Vice
 
 This General Public License does not permit incorporating your program into
 proprietary programs.  If your program is a subroutine library, you may
 consider it more useful to permit linking proprietary applications with the
-library.  If this is what you want to do, use the GNU Library General
+library.  If this is what you want to do, use the GNU Lesser General
 Public License instead of this License.
diff --git a/LICENSES/preferred/LGPL-2.1 b/LICENSES/preferred/LGPL-2.1
index 27bb4342a3..e219c53c58 100644
--- a/LICENSES/preferred/LGPL-2.1
+++ b/LICENSES/preferred/LGPL-2.1
@@ -12,492 +12,504 @@ Usage-Guide:
     SPDX-License-Identifier: LGPL-2.1+
 License-Text:
 
-GNU LESSER GENERAL PUBLIC LICENSE
-Version 2.1, February 1999
+                  GNU LESSER GENERAL PUBLIC LICENSE
+                       Version 2.1, February 1999
 
-Copyright (C) 1991, 1999 Free Software Foundation, Inc.
-51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ Copyright (C) 1991, 1999 Free Software Foundation, Inc.
+ <https://fsf.org/>
+ Everyone is permitted to copy and distribute verbatim copies
+ of this license document, but changing it is not allowed.
 
-Everyone is permitted to copy and distribute verbatim copies of this
-license document, but changing it is not allowed.
+[This is the first released version of the Lesser GPL.  It also counts
+ as the successor of the GNU Library Public License, version 2, hence
+ the version number 2.1.]
 
-[This is the first released version of the Lesser GPL. It also counts as
-the successor of the GNU Library Public License, version 2, hence the
-version number 2.1.]
+                            Preamble
 
-Preamble
+  The licenses for most software are designed to take away your
+freedom to share and change it.  By contrast, the GNU General Public
+Licenses are intended to guarantee your freedom to share and change
+free software--to make sure the software is free for all its users.
 
-The licenses for most software are designed to take away your freedom to
-share and change it. By contrast, the GNU General Public Licenses are
-intended to guarantee your freedom to share and change free software--to
-make sure the software is free for all its users.
+  This license, the Lesser General Public License, applies to some
+specially designated software packages--typically libraries--of the
+Free Software Foundation and other authors who decide to use it.  You
+can use it too, but we suggest you first think carefully about whether
+this license or the ordinary General Public License is the better
+strategy to use in any particular case, based on the explanations below.
 
-This license, the Lesser General Public License, applies to some specially
-designated software packages--typically libraries--of the Free Software
-Foundation and other authors who decide to use it. You can use it too, but
-we suggest you first think carefully about whether this license or the
-ordinary General Public License is the better strategy to use in any
-particular case, based on the explanations below.
+  When we speak of free software, we are referring to freedom of use,
+not price.  Our General Public Licenses are designed to make sure that
+you have the freedom to distribute copies of free software (and charge
+for this service if you wish); that you receive source code or can get
+it if you want it; that you can change the software and use pieces of
+it in new free programs; and that you are informed that you can do
+these things.
 
-When we speak of free software, we are referring to freedom of use, not
-price. Our General Public Licenses are designed to make sure that you have
-the freedom to distribute copies of free software (and charge for this
-service if you wish); that you receive source code or can get it if you
-want it; that you can change the software and use pieces of it in new free
-programs; and that you are informed that you can do these things.
-
-To protect your rights, we need to make restrictions that forbid
+  To protect your rights, we need to make restrictions that forbid
 distributors to deny you these rights or to ask you to surrender these
-rights. These restrictions translate to certain responsibilities for you if
-you distribute copies of the library or if you modify it.
+rights.  These restrictions translate to certain responsibilities for
+you if you distribute copies of the library or if you modify it.
 
-For example, if you distribute copies of the library, whether gratis or for
-a fee, you must give the recipients all the rights that we gave you. You
-must make sure that they, too, receive or can get the source code. If you
-link other code with the library, you must provide complete object files to
-the recipients, so that they can relink them with the library after making
-changes to the library and recompiling it. And you must show them these
-terms so they know their rights.
+  For example, if you distribute copies of the library, whether gratis
+or for a fee, you must give the recipients all the rights that we gave
+you.  You must make sure that they, too, receive or can get the source
+code.  If you link other code with the library, you must provide
+complete object files to the recipients, so that they can relink them
+with the library after making changes to the library and recompiling
+it.  And you must show them these terms so they know their rights.
 
-We protect your rights with a two-step method: (1) we copyright the
+  We protect your rights with a two-step method: (1) we copyright the
 library, and (2) we offer you this license, which gives you legal
 permission to copy, distribute and/or modify the library.
 
-To protect each distributor, we want to make it very clear that there is no
-warranty for the free library. Also, if the library is modified by someone
-else and passed on, the recipients should know that what they have is not
-the original version, so that the original author's reputation will not be
-affected by problems that might be introduced by others.
+  To protect each distributor, we want to make it very clear that
+there is no warranty for the free library.  Also, if the library is
+modified by someone else and passed on, the recipients should know
+that what they have is not the original version, so that the original
+author's reputation will not be affected by problems that might be
+introduced by others.
+
+  Finally, software patents pose a constant threat to the existence of
+any free program.  We wish to make sure that a company cannot
+effectively restrict the users of a free program by obtaining a
+restrictive license from a patent holder.  Therefore, we insist that
+any patent license obtained for a version of the library must be
+consistent with the full freedom of use specified in this license.
 
-Finally, software patents pose a constant threat to the existence of any
-free program. We wish to make sure that a company cannot effectively
-restrict the users of a free program by obtaining a restrictive license
-from a patent holder. Therefore, we insist that any patent license obtained
-for a version of the library must be consistent with the full freedom of
-use specified in this license.
+  Most GNU software, including some libraries, is covered by the
+ordinary GNU General Public License.  This license, the GNU Lesser
+General Public License, applies to certain designated libraries, and
+is quite different from the ordinary General Public License.  We use
+this license for certain libraries in order to permit linking those
+libraries into non-free programs.
 
-Most GNU software, including some libraries, is covered by the ordinary GNU
-General Public License. This license, the GNU Lesser General Public
-License, applies to certain designated libraries, and is quite different
-from the ordinary General Public License. We use this license for certain
-libraries in order to permit linking those libraries into non-free
-programs.
+  When a program is linked with a library, whether statically or using
+a shared library, the combination of the two is legally speaking a
+combined work, a derivative of the original library.  The ordinary
+General Public License therefore permits such linking only if the
+entire combination fits its criteria of freedom.  The Lesser General
+Public License permits more lax criteria for linking other code with
+the library.
 
-When a program is linked with a library, whether statically or using a
-shared library, the combination of the two is legally speaking a combined
-work, a derivative of the original library. The ordinary General Public
-License therefore permits such linking only if the entire combination fits
-its criteria of freedom. The Lesser General Public License permits more lax
-criteria for linking other code with the library.
-
-We call this license the "Lesser" General Public License because it does
-Less to protect the user's freedom than the ordinary General Public
-License. It also provides other free software developers Less of an
-advantage over competing non-free programs. These disadvantages are the
-reason we use the ordinary General Public License for many
-libraries. However, the Lesser license provides advantages in certain
+  We call this license the "Lesser" General Public License because it
+does Less to protect the user's freedom than the ordinary General
+Public License.  It also provides other free software developers Less
+of an advantage over competing non-free programs.  These disadvantages
+are the reason we use the ordinary General Public License for many
+libraries.  However, the Lesser license provides advantages in certain
 special circumstances.
 
-For example, on rare occasions, there may be a special need to encourage
-the widest possible use of a certain library, so that it becomes a de-facto
-standard. To achieve this, non-free programs must be allowed to use the
-library. A more frequent case is that a free library does the same job as
-widely used non-free libraries. In this case, there is little to gain by
-limiting the free library to free software only, so we use the Lesser
-General Public License.
+  For example, on rare occasions, there may be a special need to
+encourage the widest possible use of a certain library, so that it becomes
+a de-facto standard.  To achieve this, non-free programs must be
+allowed to use the library.  A more frequent case is that a free
+library does the same job as widely used non-free libraries.  In this
+case, there is little to gain by limiting the free library to free
+software only, so we use the Lesser General Public License.
 
-In other cases, permission to use a particular library in non-free programs
-enables a greater number of people to use a large body of free
-software. For example, permission to use the GNU C Library in non-free
-programs enables many more people to use the whole GNU operating system, as
-well as its variant, the GNU/Linux operating system.
+  In other cases, permission to use a particular library in non-free
+programs enables a greater number of people to use a large body of
+free software.  For example, permission to use the GNU C Library in
+non-free programs enables many more people to use the whole GNU
+operating system, as well as its variant, the GNU/Linux operating
+system.
 
-Although the Lesser General Public License is Less protective of the users'
-freedom, it does ensure that the user of a program that is linked with the
-Library has the freedom and the wherewithal to run that program using a
-modified version of the Library.
+  Although the Lesser General Public License is Less protective of the
+users' freedom, it does ensure that the user of a program that is
+linked with the Library has the freedom and the wherewithal to run
+that program using a modified version of the Library.
 
-The precise terms and conditions for copying, distribution and modification
-follow. Pay close attention to the difference between a "work based on the
-library" and a "work that uses the library". The former contains code
-derived from the library, whereas the latter must be combined with the
-library in order to run.
+  The precise terms and conditions for copying, distribution and
+modification follow.  Pay close attention to the difference between a
+"work based on the library" and a "work that uses the library".  The
+former contains code derived from the library, whereas the latter must
+be combined with the library in order to run.
+
+                  GNU LESSER GENERAL PUBLIC LICENSE
+   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 
-TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
+  0. This License Agreement applies to any software library or other
+program which contains a notice placed by the copyright holder or
+other authorized party saying it may be distributed under the terms of
+this Lesser General Public License (also called "this License").
+Each licensee is addressed as "you".
 
-0. This License Agreement applies to any software library or other program
-   which contains a notice placed by the copyright holder or other
-   authorized party saying it may be distributed under the terms of this
-   Lesser General Public License (also called "this License"). Each
-   licensee is addressed as "you".
+  A "library" means a collection of software functions and/or data
+prepared so as to be conveniently linked with application programs
+(which use some of those functions and data) to form executables.
 
-   A "library" means a collection of software functions and/or data
-   prepared so as to be conveniently linked with application programs
-   (which use some of those functions and data) to form executables.
+  The "Library", below, refers to any such software library or work
+which has been distributed under these terms.  A "work based on the
+Library" means either the Library or any derivative work under
+copyright law: that is to say, a work containing the Library or a
+portion of it, either verbatim or with modifications and/or translated
+straightforwardly into another language.  (Hereinafter, translation is
+included without limitation in the term "modification".)
 
-   The "Library", below, refers to any such software library or work which
-   has been distributed under these terms. A "work based on the Library"
-   means either the Library or any derivative work under copyright law:
-   that is to say, a work containing the Library or a portion of it, either
-   verbatim or with modifications and/or translated straightforwardly into
-   another language. (Hereinafter, translation is included without
-   limitation in the term "modification".)
+  "Source code" for a work means the preferred form of the work for
+making modifications to it.  For a library, complete source code means
+all the source code for all modules it contains, plus any associated
+interface definition files, plus the scripts used to control compilation
+and installation of the library.
 
-   "Source code" for a work means the preferred form of the work for making
-   modifications to it. For a library, complete source code means all the
-   source code for all modules it contains, plus any associated interface
-   definition files, plus the scripts used to control compilation and
-   installation of the library.
+  Activities other than copying, distribution and modification are not
+covered by this License; they are outside its scope.  The act of
+running a program using the Library is not restricted, and output from
+such a program is covered only if its contents constitute a work based
+on the Library (independent of the use of the Library in a tool for
+writing it).  Whether that is true depends on what the Library does
+and what the program that uses the Library does.
 
-    Activities other than copying, distribution and modification are not
-    covered by this License; they are outside its scope. The act of running
-    a program using the Library is not restricted, and output from such a
-    program is covered only if its contents constitute a work based on the
-    Library (independent of the use of the Library in a tool for writing
-    it). Whether that is true depends on what the Library does and what the
-    program that uses the Library does.
+  1. You may copy and distribute verbatim copies of the Library's
+complete source code as you receive it, in any medium, provided that
+you conspicuously and appropriately publish on each copy an
+appropriate copyright notice and disclaimer of warranty; keep intact
+all the notices that refer to this License and to the absence of any
+warranty; and distribute a copy of this License along with the
+Library.
 
-1. You may copy and distribute verbatim copies of the Library's complete
-   source code as you receive it, in any medium, provided that you
-   conspicuously and appropriately publish on each copy an appropriate
-   copyright notice and disclaimer of warranty; keep intact all the notices
-   that refer to this License and to the absence of any warranty; and
-   distribute a copy of this License along with the Library.
+  You may charge a fee for the physical act of transferring a copy,
+and you may at your option offer warranty protection in exchange for a
+fee.
+
+  2. You may modify your copy or copies of the Library or any portion
+of it, thus forming a work based on the Library, and copy and
+distribute such modifications or work under the terms of Section 1
+above, provided that you also meet all of these conditions:
 
-   You may charge a fee for the physical act of transferring a copy, and
-   you may at your option offer warranty protection in exchange for a fee.
+    a) The modified work must itself be a software library.
 
-2. You may modify your copy or copies of the Library or any portion of it,
-   thus forming a work based on the Library, and copy and distribute such
-   modifications or work under the terms of Section 1 above, provided that
-   you also meet all of these conditions:
+    b) You must cause the files modified to carry prominent notices
+    stating that you changed the files and the date of any change.
 
-   a) The modified work must itself be a software library.
+    c) You must cause the whole of the work to be licensed at no
+    charge to all third parties under the terms of this License.
 
-   b) You must cause the files modified to carry prominent notices stating
-      that you changed the files and the date of any change.
+    d) If a facility in the modified Library refers to a function or a
+    table of data to be supplied by an application program that uses
+    the facility, other than as an argument passed when the facility
+    is invoked, then you must make a good faith effort to ensure that,
+    in the event an application does not supply such function or
+    table, the facility still operates, and performs whatever part of
+    its purpose remains meaningful.
 
-   c) You must cause the whole of the work to be licensed at no charge to
-      all third parties under the terms of this License.
+    (For example, a function in a library to compute square roots has
+    a purpose that is entirely well-defined independent of the
+    application.  Therefore, Subsection 2d requires that any
+    application-supplied function or table used by this function must
+    be optional: if the application does not supply it, the square
+    root function must still compute square roots.)
 
-   d) If a facility in the modified Library refers to a function or a table
-      of data to be supplied by an application program that uses the
-      facility, other than as an argument passed when the facility is
-      invoked, then you must make a good faith effort to ensure that, in
-      the event an application does not supply such function or table, the
-      facility still operates, and performs whatever part of its purpose
-      remains meaningful.
+These requirements apply to the modified work as a whole.  If
+identifiable sections of that work are not derived from the Library,
+and can be reasonably considered independent and separate works in
+themselves, then this License, and its terms, do not apply to those
+sections when you distribute them as separate works.  But when you
+distribute the same sections as part of a whole which is a work based
+on the Library, the distribution of the whole must be on the terms of
+this License, whose permissions for other licensees extend to the
+entire whole, and thus to each and every part regardless of who wrote
+it.
 
-   (For example, a function in a library to compute square roots has a
-    purpose that is entirely well-defined independent of the
-    application. Therefore, Subsection 2d requires that any
-    application-supplied function or table used by this function must be
-    optional: if the application does not supply it, the square root
-    function must still compute square roots.)
+Thus, it is not the intent of this section to claim rights or contest
+your rights to work written entirely by you; rather, the intent is to
+exercise the right to control the distribution of derivative or
+collective works based on the Library.
 
-   These requirements apply to the modified work as a whole. If
-   identifiable sections of that work are not derived from the Library, and
-   can be reasonably considered independent and separate works in
-   themselves, then this License, and its terms, do not apply to those
-   sections when you distribute them as separate works. But when you
-   distribute the same sections as part of a whole which is a work based on
-   the Library, the distribution of the whole must be on the terms of this
-   License, whose permissions for other licensees extend to the entire
-   whole, and thus to each and every part regardless of who wrote it.
+In addition, mere aggregation of another work not based on the Library
+with the Library (or with a work based on the Library) on a volume of
+a storage or distribution medium does not bring the other work under
+the scope of this License.
 
-   Thus, it is not the intent of this section to claim rights or contest
-   your rights to work written entirely by you; rather, the intent is to
-   exercise the right to control the distribution of derivative or
-   collective works based on the Library.
+  3. You may opt to apply the terms of the ordinary GNU General Public
+License instead of this License to a given copy of the Library.  To do
+this, you must alter all the notices that refer to this License, so
+that they refer to the ordinary GNU General Public License, version 2,
+instead of to this License.  (If a newer version than version 2 of the
+ordinary GNU General Public License has appeared, then you can specify
+that version instead if you wish.)  Do not make any other change in
+these notices.
+
+  Once this change is made in a given copy, it is irreversible for
+that copy, so the ordinary GNU General Public License applies to all
+subsequent copies and derivative works made from that copy.
 
-   In addition, mere aggregation of another work not based on the Library
-   with the Library (or with a work based on the Library) on a volume of a
-   storage or distribution medium does not bring the other work under the
-   scope of this License.
+  This option is useful when you wish to copy part of the code of
+the Library into a program that is not a library.
 
-3. You may opt to apply the terms of the ordinary GNU General Public
-   License instead of this License to a given copy of the Library. To do
-   this, you must alter all the notices that refer to this License, so that
-   they refer to the ordinary GNU General Public License, version 2,
-   instead of to this License. (If a newer version than version 2 of the
-   ordinary GNU General Public License has appeared, then you can specify
-   that version instead if you wish.) Do not make any other change in these
-   notices.
+  4. You may copy and distribute the Library (or a portion or
+derivative of it, under Section 2) in object code or executable form
+under the terms of Sections 1 and 2 above provided that you accompany
+it with the complete corresponding machine-readable source code, which
+must be distributed under the terms of Sections 1 and 2 above on a
+medium customarily used for software interchange.
 
-   Once this change is made in a given copy, it is irreversible for that
-   copy, so the ordinary GNU General Public License applies to all
-   subsequent copies and derivative works made from that copy.
+  If distribution of object code is made by offering access to copy
+from a designated place, then offering equivalent access to copy the
+source code from the same place satisfies the requirement to
+distribute the source code, even though third parties are not
+compelled to copy the source along with the object code.
 
-   This option is useful when you wish to copy part of the code of the
-   Library into a program that is not a library.
+  5. A program that contains no derivative of any portion of the
+Library, but is designed to work with the Library by being compiled or
+linked with it, is called a "work that uses the Library".  Such a
+work, in isolation, is not a derivative work of the Library, and
+therefore falls outside the scope of this License.
 
-4. You may copy and distribute the Library (or a portion or derivative of
-   it, under Section 2) in object code or executable form under the terms
-   of Sections 1 and 2 above provided that you accompany it with the
-   complete corresponding machine-readable source code, which must be
-   distributed under the terms of Sections 1 and 2 above on a medium
-   customarily used for software interchange.
+  However, linking a "work that uses the Library" with the Library
+creates an executable that is a derivative of the Library (because it
+contains portions of the Library), rather than a "work that uses the
+library".  The executable is therefore covered by this License.
+Section 6 states terms for distribution of such executables.
 
-   If distribution of object code is made by offering access to copy from a
-   designated place, then offering equivalent access to copy the source
-   code from the same place satisfies the requirement to distribute the
-   source code, even though third parties are not compelled to copy the
-   source along with the object code.
+  When a "work that uses the Library" uses material from a header file
+that is part of the Library, the object code for the work may be a
+derivative work of the Library even though the source code is not.
+Whether this is true is especially significant if the work can be
+linked without the Library, or if the work is itself a library.  The
+threshold for this to be true is not precisely defined by law.
 
-5. A program that contains no derivative of any portion of the Library, but
-   is designed to work with the Library by being compiled or linked with
-   it, is called a "work that uses the Library". Such a work, in isolation,
-   is not a derivative work of the Library, and therefore falls outside the
-   scope of this License.
+  If such an object file uses only numerical parameters, data
+structure layouts and accessors, and small macros and small inline
+functions (ten lines or less in length), then the use of the object
+file is unrestricted, regardless of whether it is legally a derivative
+work.  (Executables containing this object code plus portions of the
+Library will still fall under Section 6.)
 
-   However, linking a "work that uses the Library" with the Library creates
-   an executable that is a derivative of the Library (because it contains
-   portions of the Library), rather than a "work that uses the
-   library". The executable is therefore covered by this License. Section 6
-   states terms for distribution of such executables.
+  Otherwise, if the work is a derivative of the Library, you may
+distribute the object code for the work under the terms of Section 6.
+Any executables containing that work also fall under Section 6,
+whether or not they are linked directly with the Library itself.
+
+  6. As an exception to the Sections above, you may also combine or
+link a "work that uses the Library" with the Library to produce a
+work containing portions of the Library, and distribute that work
+under terms of your choice, provided that the terms permit
+modification of the work for the customer's own use and reverse
+engineering for debugging such modifications.
 
-   When a "work that uses the Library" uses material from a header file
-   that is part of the Library, the object code for the work may be a
-   derivative work of the Library even though the source code is
-   not. Whether this is true is especially significant if the work can be
-   linked without the Library, or if the work is itself a library. The
-   threshold for this to be true is not precisely defined by law.
+  You must give prominent notice with each copy of the work that the
+Library is used in it and that the Library and its use are covered by
+this License.  You must supply a copy of this License.  If the work
+during execution displays copyright notices, you must include the
+copyright notice for the Library among them, as well as a reference
+directing the user to the copy of this License.  Also, you must do one
+of these things:
 
-   If such an object file uses only numerical parameters, data structure
-   layouts and accessors, and small macros and small inline functions (ten
-   lines or less in length), then the use of the object file is
-   unrestricted, regardless of whether it is legally a derivative
-   work. (Executables containing this object code plus portions of the
-   Library will still fall under Section 6.)
+    a) Accompany the work with the complete corresponding
+    machine-readable source code for the Library including whatever
+    changes were used in the work (which must be distributed under
+    Sections 1 and 2 above); and, if the work is an executable linked
+    with the Library, with the complete machine-readable "work that
+    uses the Library", as object code and/or source code, so that the
+    user can modify the Library and then relink to produce a modified
+    executable containing the modified Library.  (It is understood
+    that the user who changes the contents of definitions files in the
+    Library will not necessarily be able to recompile the application
+    to use the modified definitions.)
 
-   Otherwise, if the work is a derivative of the Library, you may
-   distribute the object code for the work under the terms of Section
-   6. Any executables containing that work also fall under Section 6,
-   whether or not they are linked directly with the Library itself.
+    b) Use a suitable shared library mechanism for linking with the
+    Library.  A suitable mechanism is one that (1) uses at run time a
+    copy of the library already present on the user's computer system,
+    rather than copying library functions into the executable, and (2)
+    will operate properly with a modified version of the library, if
+    the user installs one, as long as the modified version is
+    interface-compatible with the version that the work was made with.
 
-6. As an exception to the Sections above, you may also combine or link a
-   "work that uses the Library" with the Library to produce a work
-   containing portions of the Library, and distribute that work under terms
-   of your choice, provided that the terms permit modification of the work
-   for the customer's own use and reverse engineering for debugging such
-   modifications.
+    c) Accompany the work with a written offer, valid for at
+    least three years, to give the same user the materials
+    specified in Subsection 6a, above, for a charge no more
+    than the cost of performing this distribution.
 
-   You must give prominent notice with each copy of the work that the
-   Library is used in it and that the Library and its use are covered by
-   this License. You must supply a copy of this License. If the work during
-   execution displays copyright notices, you must include the copyright
-   notice for the Library among them, as well as a reference directing the
-   user to the copy of this License. Also, you must do one of these things:
+    d) If distribution of the work is made by offering access to copy
+    from a designated place, offer equivalent access to copy the above
+    specified materials from the same place.
 
-   a) Accompany the work with the complete corresponding machine-readable
-      source code for the Library including whatever changes were used in
-      the work (which must be distributed under Sections 1 and 2 above);
-      and, if the work is an executable linked with the Library, with the
-      complete machine-readable "work that uses the Library", as object
-      code and/or source code, so that the user can modify the Library and
-      then relink to produce a modified executable containing the modified
-      Library. (It is understood that the user who changes the contents of
-      definitions files in the Library will not necessarily be able to
-      recompile the application to use the modified definitions.)
+    e) Verify that the user has already received a copy of these
+    materials or that you have already sent this user a copy.
 
-   b) Use a suitable shared library mechanism for linking with the
-      Library. A suitable mechanism is one that (1) uses at run time a copy
-      of the library already present on the user's computer system, rather
-      than copying library functions into the executable, and (2) will
-      operate properly with a modified version of the library, if the user
-      installs one, as long as the modified version is interface-compatible
-      with the version that the work was made with.
+  For an executable, the required form of the "work that uses the
+Library" must include any data and utility programs needed for
+reproducing the executable from it.  However, as a special exception,
+the materials to be distributed need not include anything that is
+normally distributed (in either source or binary form) with the major
+components (compiler, kernel, and so on) of the operating system on
+which the executable runs, unless that component itself accompanies
+the executable.
 
-   c) Accompany the work with a written offer, valid for at least three
-      years, to give the same user the materials specified in Subsection
-      6a, above, for a charge no more than the cost of performing this
-      distribution.
+  It may happen that this requirement contradicts the license
+restrictions of other proprietary libraries that do not normally
+accompany the operating system.  Such a contradiction means you cannot
+use both them and the Library together in an executable that you
+distribute.
+
+  7. You may place library facilities that are a work based on the
+Library side-by-side in a single library together with other library
+facilities not covered by this License, and distribute such a combined
+library, provided that the separate distribution of the work based on
+the Library and of the other library facilities is otherwise
+permitted, and provided that you do these two things:
 
-   d) If distribution of the work is made by offering access to copy from a
-      designated place, offer equivalent access to copy the above specified
-      materials from the same place.
+    a) Accompany the combined library with a copy of the same work
+    based on the Library, uncombined with any other library
+    facilities.  This must be distributed under the terms of the
+    Sections above.
 
-   e) Verify that the user has already received a copy of these materials
-      or that you have already sent this user a copy.
+    b) Give prominent notice with the combined library of the fact
+    that part of it is a work based on the Library, and explaining
+    where to find the accompanying uncombined form of the same work.
 
-   For an executable, the required form of the "work that uses the Library"
-   must include any data and utility programs needed for reproducing the
-   executable from it. However, as a special exception, the materials to be
-   distributed need not include anything that is normally distributed (in
-   either source or binary form) with the major components (compiler,
-   kernel, and so on) of the operating system on which the executable runs,
-   unless that component itself accompanies the executable.
+  8. You may not copy, modify, sublicense, link with, or distribute
+the Library except as expressly provided under this License.  Any
+attempt otherwise to copy, modify, sublicense, link with, or
+distribute the Library is void, and will automatically terminate your
+rights under this License.  However, parties who have received copies,
+or rights, from you under this License will not have their licenses
+terminated so long as such parties remain in full compliance.
 
-   It may happen that this requirement contradicts the license restrictions
-   of other proprietary libraries that do not normally accompany the
-   operating system. Such a contradiction means you cannot use both them
-   and the Library together in an executable that you distribute.
+  9. You are not required to accept this License, since you have not
+signed it.  However, nothing else grants you permission to modify or
+distribute the Library or its derivative works.  These actions are
+prohibited by law if you do not accept this License.  Therefore, by
+modifying or distributing the Library (or any work based on the
+Library), you indicate your acceptance of this License to do so, and
+all its terms and conditions for copying, distributing or modifying
+the Library or works based on it.
 
-7. You may place library facilities that are a work based on the Library
-   side-by-side in a single library together with other library facilities
-   not covered by this License, and distribute such a combined library,
-   provided that the separate distribution of the work based on the Library
-   and of the other library facilities is otherwise permitted, and provided
-   that you do these two things:
+  10. Each time you redistribute the Library (or any work based on the
+Library), the recipient automatically receives a license from the
+original licensor to copy, distribute, link with or modify the Library
+subject to these terms and conditions.  You may not impose any further
+restrictions on the recipients' exercise of the rights granted herein.
+You are not responsible for enforcing compliance by third parties with
+this License.
+
+  11. If, as a consequence of a court judgment or allegation of patent
+infringement or for any other reason (not limited to patent issues),
+conditions are imposed on you (whether by court order, agreement or
+otherwise) that contradict the conditions of this License, they do not
+excuse you from the conditions of this License.  If you cannot
+distribute so as to satisfy simultaneously your obligations under this
+License and any other pertinent obligations, then as a consequence you
+may not distribute the Library at all.  For example, if a patent
+license would not permit royalty-free redistribution of the Library by
+all those who receive copies directly or indirectly through you, then
+the only way you could satisfy both it and this License would be to
+refrain entirely from distribution of the Library.
 
-   a) Accompany the combined library with a copy of the same work based on
-      the Library, uncombined with any other library facilities. This must
-      be distributed under the terms of the Sections above.
+If any portion of this section is held invalid or unenforceable under any
+particular circumstance, the balance of the section is intended to apply,
+and the section as a whole is intended to apply in other circumstances.
 
-   b) Give prominent notice with the combined library of the fact that part
-      of it is a work based on the Library, and explaining where to find
-      the accompanying uncombined form of the same work.
+It is not the purpose of this section to induce you to infringe any
+patents or other property right claims or to contest validity of any
+such claims; this section has the sole purpose of protecting the
+integrity of the free software distribution system which is
+implemented by public license practices.  Many people have made
+generous contributions to the wide range of software distributed
+through that system in reliance on consistent application of that
+system; it is up to the author/donor to decide if he or she is willing
+to distribute software through any other system and a licensee cannot
+impose that choice.
 
-8. You may not copy, modify, sublicense, link with, or distribute the
-   Library except as expressly provided under this License. Any attempt
-   otherwise to copy, modify, sublicense, link with, or distribute the
-   Library is void, and will automatically terminate your rights under this
-   License. However, parties who have received copies, or rights, from you
-   under this License will not have their licenses terminated so long as
-   such parties remain in full compliance.
+This section is intended to make thoroughly clear what is believed to
+be a consequence of the rest of this License.
 
-9. You are not required to accept this License, since you have not signed
-   it. However, nothing else grants you permission to modify or distribute
-   the Library or its derivative works. These actions are prohibited by law
-   if you do not accept this License. Therefore, by modifying or
-   distributing the Library (or any work based on the Library), you
-   indicate your acceptance of this License to do so, and all its terms and
-   conditions for copying, distributing or modifying the Library or works
-   based on it.
+  12. If the distribution and/or use of the Library is restricted in
+certain countries either by patents or by copyrighted interfaces, the
+original copyright holder who places the Library under this License may add
+an explicit geographical distribution limitation excluding those countries,
+so that distribution is permitted only in or among countries not thus
+excluded.  In such case, this License incorporates the limitation as if
+written in the body of this License.
 
-10. Each time you redistribute the Library (or any work based on the
-    Library), the recipient automatically receives a license from the
-    original licensor to copy, distribute, link with or modify the Library
-    subject to these terms and conditions. You may not impose any further
-    restrictions on the recipients' exercise of the rights granted
-    herein. You are not responsible for enforcing compliance by third
-    parties with this License.
+  13. The Free Software Foundation may publish revised and/or new
+versions of the Lesser General Public License from time to time.
+Such new versions will be similar in spirit to the present version,
+but may differ in detail to address new problems or concerns.
 
-11. If, as a consequence of a court judgment or allegation of patent
-    infringement or for any other reason (not limited to patent issues),
-    conditions are imposed on you (whether by court order, agreement or
-    otherwise) that contradict the conditions of this License, they do not
-    excuse you from the conditions of this License. If you cannot
-    distribute so as to satisfy simultaneously your obligations under this
-    License and any other pertinent obligations, then as a consequence you
-    may not distribute the Library at all. For example, if a patent license
-    would not permit royalty-free redistribution of the Library by all
-    those who receive copies directly or indirectly through you, then the
-    only way you could satisfy both it and this License would be to refrain
-    entirely from distribution of the Library.
+Each version is given a distinguishing version number.  If the Library
+specifies a version number of this License which applies to it and
+"any later version", you have the option of following the terms and
+conditions either of that version or of any later version published by
+the Free Software Foundation.  If the Library does not specify a
+license version number, you may choose any version ever published by
+the Free Software Foundation.
+
+  14. If you wish to incorporate parts of the Library into other free
+programs whose distribution conditions are incompatible with these,
+write to the author to ask for permission.  For software which is
+copyrighted by the Free Software Foundation, write to the Free
+Software Foundation; we sometimes make exceptions for this.  Our
+decision will be guided by the two goals of preserving the free status
+of all derivatives of our free software and of promoting the sharing
+and reuse of software generally.
 
-    If any portion of this section is held invalid or unenforceable under
-    any particular circumstance, the balance of the section is intended to
-    apply, and the section as a whole is intended to apply in other
-    circumstances.
+                            NO WARRANTY
 
-    It is not the purpose of this section to induce you to infringe any
-    patents or other property right claims or to contest validity of any
-    such claims; this section has the sole purpose of protecting the
-    integrity of the free software distribution system which is implemented
-    by public license practices. Many people have made generous
-    contributions to the wide range of software distributed through that
-    system in reliance on consistent application of that system; it is up
-    to the author/donor to decide if he or she is willing to distribute
-    software through any other system and a licensee cannot impose that
-    choice.
+  15. BECAUSE THE LIBRARY IS LICENSED FREE OF CHARGE, THERE IS NO
+WARRANTY FOR THE LIBRARY, TO THE EXTENT PERMITTED BY APPLICABLE LAW.
+EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR
+OTHER PARTIES PROVIDE THE LIBRARY "AS IS" WITHOUT WARRANTY OF ANY
+KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
+IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
+LIBRARY IS WITH YOU.  SHOULD THE LIBRARY PROVE DEFECTIVE, YOU ASSUME
+THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
 
-    This section is intended to make thoroughly clear what is believed to
-    be a consequence of the rest of this License.
+  16. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN
+WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY
+AND/OR REDISTRIBUTE THE LIBRARY AS PERMITTED ABOVE, BE LIABLE TO YOU
+FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR
+CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
+LIBRARY (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
+RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
+FAILURE OF THE LIBRARY TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
+SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
+DAMAGES.
 
-12. If the distribution and/or use of the Library is restricted in certain
-    countries either by patents or by copyrighted interfaces, the original
-    copyright holder who places the Library under this License may add an
-    explicit geographical distribution limitation excluding those
-    countries, so that distribution is permitted only in or among countries
-    not thus excluded. In such case, this License incorporates the
-    limitation as if written in the body of this License.
+                     END OF TERMS AND CONDITIONS
+
+           How to Apply These Terms to Your New Libraries
 
-13. The Free Software Foundation may publish revised and/or new versions of
-    the Lesser General Public License from time to time. Such new versions
-    will be similar in spirit to the present version, but may differ in
-    detail to address new problems or concerns.
-
-    Each version is given a distinguishing version number. If the Library
-    specifies a version number of this License which applies to it and "any
-    later version", you have the option of following the terms and
-    conditions either of that version or of any later version published by
-    the Free Software Foundation. If the Library does not specify a license
-    version number, you may choose any version ever published by the Free
-    Software Foundation.
-
-14. If you wish to incorporate parts of the Library into other free
-    programs whose distribution conditions are incompatible with these,
-    write to the author to ask for permission. For software which is
-    copyrighted by the Free Software Foundation, write to the Free Software
-    Foundation; we sometimes make exceptions for this. Our decision will be
-    guided by the two goals of preserving the free status of all
-    derivatives of our free software and of promoting the sharing and reuse
-    of software generally.
-
-NO WARRANTY
-
-15. BECAUSE THE LIBRARY IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
-    FOR THE LIBRARY, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
-    OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
-    PROVIDE THE LIBRARY "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-    EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
-    ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE LIBRARY IS WITH
-    YOU. SHOULD THE LIBRARY PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
-    NECESSARY SERVICING, REPAIR OR CORRECTION.
-
-16. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
-    WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
-    REDISTRIBUTE THE LIBRARY AS PERMITTED ABOVE, BE LIABLE TO YOU FOR
-    DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL
-    DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE LIBRARY
-    (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED
-    INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF
-    THE LIBRARY TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF SUCH HOLDER OR
-    OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
-
-END OF TERMS AND CONDITIONS
-
-How to Apply These Terms to Your New Libraries
-
-If you develop a new library, and you want it to be of the greatest
+  If you develop a new library, and you want it to be of the greatest
 possible use to the public, we recommend making it free software that
-everyone can redistribute and change. You can do so by permitting
+everyone can redistribute and change.  You can do so by permitting
 redistribution under these terms (or, alternatively, under the terms of the
 ordinary General Public License).
 
-To apply these terms, attach the following notices to the library. It is
+  To apply these terms, attach the following notices to the library.  It is
 safest to attach them to the start of each source file to most effectively
 convey the exclusion of warranty; and each file should have at least the
 "copyright" line and a pointer to where the full notice is found.
 
-one line to give the library's name and an idea of what it does.
-Copyright (C) year name of author
+    <one line to give the library's name and a brief idea of what it does.>
+    Copyright (C) <year>  <name of author>
 
-This library is free software; you can redistribute it and/or modify it
-under the terms of the GNU Lesser General Public License as published by
-the Free Software Foundation; either version 2.1 of the License, or (at
-your option) any later version.
+    This library is free software; you can redistribute it and/or
+    modify it under the terms of the GNU Lesser General Public
+    License as published by the Free Software Foundation; either
+    version 2.1 of the License, or (at your option) any later version.
 
-This library is distributed in the hope that it will be useful, but WITHOUT
-ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
-for more details.
+    This library is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+    Lesser General Public License for more details.
 
-You should have received a copy of the GNU Lesser General Public License
-along with this library; if not, write to the Free Software Foundation,
-Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA Also add
-information on how to contact you by electronic and paper mail.
+    You should have received a copy of the GNU Lesser General Public
+    License along with this library; if not, see <https://www.gnu.org/licenses/>.
+
+Also add information on how to contact you by electronic and paper mail.
 
 You should also get your employer (if you work as a programmer) or your
 school, if any, to sign a "copyright disclaimer" for the library, if
-necessary. Here is a sample; alter the names:
+necessary.  Here is a sample; alter the names:
 
-Yoyodyne, Inc., hereby disclaims all copyright interest in
-the library `Frob' (a library for tweaking knobs) written
-by James Random Hacker.
+  Yoyodyne, Inc., hereby disclaims all copyright interest in the
+  library `Frob' (a library for tweaking knobs) written by James Random Hacker.
+
+  <signature of Moe Ghoul>, 1 April 1990
+  Moe Ghoul, President of Vice
 
-signature of Ty Coon, 1 April 1990
-Ty Coon, President of Vice
 That's all there is to it!
diff --git a/debian/copyright b/debian/copyright
index 49afd3f561..22a580d604 100644
--- a/debian/copyright
+++ b/debian/copyright
@@ -21,11 +21,11 @@ A copy of the FDL is appended below:
 
 -------------------------------------------------------------------------------
 
-		GNU Free Documentation License
-		   Version 1.1, March 2000
+                GNU Free Documentation License
+                   Version 1.1, March 2000
 
  Copyright (C) 2000  Free Software Foundation, Inc.
-     51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
+     <https://fsf.org/>
  Everyone is permitted to copy and distribute verbatim copies
  of this license document, but changing it is not allowed.
 
@@ -340,7 +340,7 @@ The Free Software Foundation may publish new, revised versions
 of the GNU Free Documentation License from time to time.  Such new
 versions will be similar in spirit to the present version, but may
 differ in detail to address new problems or concerns.  See
-http://www.gnu.org/copyleft/.
+https://www.gnu.org/licenses/.
 
 Each version of the License is given a distinguishing version number.
 If the Document specifies that a particular numbered version of this
diff --git a/lustre/utils/LCOPYING b/lustre/utils/LCOPYING
index 6e12b62aff..5f84f87955 100644
--- a/lustre/utils/LCOPYING
+++ b/lustre/utils/LCOPYING
@@ -9,12 +9,11 @@ lustre/utils/liblustreapi_util.c
 lustre/utils/liblustreapi_swap.c
 lustre/utils/lustreapi_internal.h
 -------------------------------------------------------------------------------
-		  GNU LESSER GENERAL PUBLIC LICENSE
+                  GNU LESSER GENERAL PUBLIC LICENSE
                        Version 2.1, February 1999
 
  Copyright (C) 1991, 1999 Free Software Foundation, Inc.
-
- 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
+ <https://fsf.org/>
  Everyone is permitted to copy and distribute verbatim copies
  of this license document, but changing it is not allowed.
 
-- 
2.49.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
