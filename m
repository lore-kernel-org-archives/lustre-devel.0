From: Erich Focht <efocht@gmail.com>
Date: Wed, 04 May 2011 18:36:36 +0200
Subject: [Lustre-devel] accessing object version from user space?
In-Reply-To: <AD1E6969-051D-41AA-BE5D-E89F114C0317@whamcloud.com>
References: <4DBFF92D.6070304@gmail.com>
	<AD1E6969-051D-41AA-BE5D-E89F114C0317@whamcloud.com>
Message-ID: <4DC18094.6050007@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 05/03/2011 09:35 PM, Andreas Dilger wrote:
> On May 3, 2011, at 06:46, Erich Focht wrote:
>> is there a way to access the file objects version information (epoch, transno, whatever is used
>> for version based recovery) from user space? If yes, is that possible for lustre 1.8.x, too?
>> Looking for a way to check (quickly) whether a file has changed while copying it away...
> 
> Comparing the ctime at the start/end of the copy should be enough for that.

You mean ctime of Lustre file, or ctime of file objects on OSTs? Is there a nice way to access those?
Maybe I'm a bit paranoid, but what if a client loses connection to MDS while continuing to write to
OSTs? Just a thought...

Thanks & best regards,
Erich
