From: Degremont, Aurelien <degremoa@amazon.com>
Date: Thu, 12 Sep 2019 10:20:16 +0000
Subject: [lustre-devel] [lustre-discuss] Do not recreate OST objects on
 OST replacement
In-Reply-To: <7B07B797-354B-4F09-AE5F-7DA1BA274C0D@whamcloud.com>
References: <765FE877-E7A8-476C-823C-2A01EC6F1787@amazon.com>
 <7B07B797-354B-4F09-AE5F-7DA1BA274C0D@whamcloud.com>
Message-ID: <A5388C56-3806-4FBA-AE78-2AACFB5F056A@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

(Relocation this to lustre-devel)

The problem is related to the behavior when accessing files located on this OST.
If you replace this OST and some files are still referring it, you will have 2 different behaviors

  *   If the object was not recreated, you will get some error accessing it (likely ENOENT)
  *   If the object was recreated, the file will be accessible without error BUT:

If the object is recreated and the stripe count is 1, file is empty, size is 0.
If stripe count was greater than 1, you will have different behavior with file size between 0 and the original size and file content with holes.
But, from the user point of view the file will look OK, without any error, even if the data were severely impacted.
That's why I'm not fond of this behavior were files with missing data looks nice from a user point of view.

If admins want to recreate the file objects because it is better for them, lfsck with create object option will take care of that. No need for the OST to do it automatically.
If admins prefer to not recreate those file objects, that's not possible now.

Looking at the code, the OST is recreating the last batch of object creation when starting after being replaced.
What do you think of not doing that in this case if the current object ID is 0.
Looking for OBD_FL_DELORPHAN flag and ofd_seq_last_oid() == 0 ?
Do you see side effects?


Aur?lien

De : Andreas Dilger <adilger@whamcloud.com>
Date : jeudi 12 septembre 2019 ? 11:45
? : "Degremont, Aurelien" <degremoa@amazon.com>
Cc : "lustre-discuss at lists.lustre.org" <lustre-discuss@lists.lustre.org>
Objet : Re: [lustre-discuss] Do not recreate OST objects on OST replacement




On Sep 10, 2019, at 10:23, Degremont, Aurelien <degremoa at amazon.com<mailto:degremoa@amazon.com>> wrote:

Hello

When an OST dies and you have no choice but replacing it with a newly freshly formatted one (using mkfs --replace), Lustre runs a resynchronization mechanisms between the MDT and the OST.
The MDT will sent the last object ID it knows for this OST and the OST will compare this value with its own counter (0 for a freshly formatted OST).
If the difference is greater than 100,000 objects, it will recreate only the last 10,000, if not, it will recreate all the missing objects.

I would like it to avoid recreating any objects. The missing ones are lost and just start recreating new ones. Is there a way to achieve that?

It isn't currently possible to completely avoid recreating these objects.  Normally it isn't a huge problem, given the size of normal OSTs.  This is done to ensure that if the MDS has previously allocated those objects there will be objects available for the clients to write to them. LFSCK can be used to clean up these orphan objects if they are not in use.


Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud





-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190912/9c12f7a1/attachment.html>
