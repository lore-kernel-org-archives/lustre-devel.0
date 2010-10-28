From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Thu, 28 Oct 2010 17:15:34 +0800
Subject: [Lustre-devel] changelog for whole filesystem?
In-Reply-To: <4CC84509.4050609@cea.fr>
References: <855B43E2-1D24-4095-ABE7-643A3ADAD67D@oracle.com>
	<4CC84509.4050609@cea.fr>
Message-ID: <9759789F-8FD0-464F-9632-E31F0F45287C@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-10-27, at 23:28, LEIBOVICI Thomas <thomas.leibovici@cea.fr> wrote:
> Would this special log have the same record structure as current changelogs, or a different structure with more information?
> Depending on how this iterator works, maybe we can avoid RPCs (for stat, fid2path, get_stripe, hsm_state_get...) if this info is available when the log record is generated.

My thought was to use the same format for the changelog so that it would be easy to use the same API to use the "whole filesystem" traversal log and then transfer over to the standard "changes only" changelog. In fact, it might make sense to make this atomic so that this is a flag on a regular changelog open, and it will continue after the traversal is completed to the changelog for any changes that happened since the traversal started. 

> Anyhow, this feature sounds very interesting. We'll be glad to help, if you need taskforce for implementing such a feature.
> 
> Thomas
> 
> Andreas Dilger wrote:
>> I had an interesting idea today during a discussion on HSM.  One of the issues with enabling HSM today is that a full-filesystem scan must be done initially to populate the policy engine database.
>> 
>> I was thinking that it would be useful to have a virtual changelog that provides a feed from internally traversing the whole filesystem in an efficient manner.  For bug 22741 we have implemented a virtual index in the OSD which will return all of the in-use ldiskfs inodes in inode-number order (which is the fastest way to read/stat all of the inodes).  It probably wouldn't be too hard to hook this OSD callback into the changelog API, so that reading a special changelog file would return all of the files in the filesystem.  It is possible to generate the full pathnames of these inodes via the "link" xattr, if that is needed.
>> 
>> Cheers, Andreas
>> --
>> Andreas Dilger
>> Lustre Technical Lead
>> Oracle Corporation Canada Inc.
>> 
>>  
> 
