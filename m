From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 5 May 2011 10:48:45 -0600
Subject: [Lustre-devel] accessing object version from user space?
In-Reply-To: <4DC18094.6050007@gmail.com>
References: <4DBFF92D.6070304@gmail.com>
	<AD1E6969-051D-41AA-BE5D-E89F114C0317@whamcloud.com>
	<4DC18094.6050007@gmail.com>
Message-ID: <5468F3C7-6632-435F-B437-C2BA2AAD3968@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 4, 2011, at 10:36, Erich Focht wrote:
> On 05/03/2011 09:35 PM, Andreas Dilger wrote:
>> On May 3, 2011, at 06:46, Erich Focht wrote:
>>> is there a way to access the file objects version information (epoch, transno, whatever is used
>>> for version based recovery) from user space? If yes, is that possible for lustre 1.8.x, too?
>>> Looking for a way to check (quickly) whether a file has changed while copying it away...
>> 
>> Comparing the ctime at the start/end of the copy should be enough for that.
> 
> You mean ctime of Lustre file, or ctime of file objects on OSTs? Is there a
> nice way to access those?
> Maybe I'm a bit paranoid, but what if a client loses connection to MDS while
> continuing to write to OSTs? Just a thought...

The ctime is derived from the latest ctime of the MDS inode and OST objects (ctime is not allowed to go backward), so even if the client is disconnected from the MDS it will get the latest ctime from the OSTs if the files are being modified there.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
