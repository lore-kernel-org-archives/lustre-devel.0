From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Thu, 03 Jul 2008 18:03:20 +0200
Subject: [Lustre-devel] Quota and Lustre HSM
Message-ID: <486CF848.7090904@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

We got discussion with Andreas and Nathan concerning the best way to 
support quota with Lustre HSM.
I'd like to discuss and clarify what should be the correct behavior in 
this case.


1 - Current status

Here how the Lustre filesystem will behave with current quota system 
enabled and an active HSM binding.

1.1 Read on a purged file

  * User A reads a purged file with enough free quota

   o The file is copied back from the HSM.
   o User quota increases without new data created by user.

  * User A reads a purged file with no enough quota.

   o The file cannot be copied back from the HSM.
   o I/O failed (Same issue that when the FS is full with HSM support 
enabled).

1.2 Automatic space management

  * One of User A files is purged by the Space Manager, without actions 
from user A.

   o User quota decreases without reason from user point of view.

2 - Questions

Is that the expected behavior?
If not what should be changed?
What should be the correct behavior?
How this could be implemented?

3 - Possible solutions

* Not enough quota

When not enough quota is available for filling back a purged file when 
the user try to read it, a solution could be to trigger purges on the 
other user files.

But it could impossible to find purge candidates.

* Improve quota management

Another approach could be to not removed purged blocks from user quota. 
A purged file is still considering using as much space as its current 
size. This solves all the issues presented before.

HSM feature will track the purged window for each file anyway, so we can 
compute the purged window size. When the user quota is classically 
compute on a filesystem, we will just need to add it to the window size. 
(Could be a problem if the file was sparse).


-- 
Aurelien Degremont
CEA
