From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Sun, 14 Nov 2010 15:48:50 -0600
Subject: [Lustre-devel] Lustre RPC related information
In-Reply-To: <AANLkTikTxeZQdUo1pmLaoHFQq77gMqz1w9WLMz2p6oOK@mail.gmail.com>
References: <AANLkTik96oNGfaK5sPaLcuWO=pUTN9gs9+ynN6=V4mgU@mail.gmail.com>
	<AANLkTikTxeZQdUo1pmLaoHFQq77gMqz1w9WLMz2p6oOK@mail.gmail.com>
Message-ID: <6EB2F76C-1A7D-4B92-AAB3-B4022EEA970F@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Vilobh Meshram wrote:
> Amongst all these RPC which all are for lock related request and which do not ask for locks .E.g OBD_PING does not asks for locks where as LDLM_ENQUEUE is the main entry point for handling lock related request.It would also be great if you can tell me with which system call which RPC might be invoked.Thanks.
> 
> 
> MDS_CONNECT
> MDS_DISCONNECT

These are used to do initial connect to the MDS service. 

> MDS_GETSTATUS

Gets the root inode for the filesystem. 

> MDS_GETATTR
> MDS_GETATTR_NAME


Gets inode attributes (by inode number or by name), but not used very often since client prefers to get attributes in conjunction with a lock. 

> MDS_SETXATTR
> MDS_GETXATTR 

For getting or setting extended attributes (e.g. ACLs or user xattrs). 

> MDS_STATFS

Gets filesystem space usage (blocks and inodes). 

> MDS_READPAGE

Read aone or more directory pages. 

> MDS_REINT

All filesystem modifying RPCs. 

> MDS_CLOSE

Close a file. 
> MDS_DONE_WRITING

For size-on-mds, currently unused. 

> MDS_PIN

Pin current working directory, currently unused. 

> MDS_SYNC

Sync MDT filesystem  operations to disk. 

> MDS_SET_INFO

Misc flags setting (e.g. Set client export read-only). 

> MDS_QUOTACHECK  
> MDS_QUOTACTL 
> OBD_QC_CALLBACK


For quota checks. 

> MDS_WRITEPAGE 

Currently unused (for CMD directory split, but will probably be removed and done differently). 

> MDS_IS_SUBDIR    

For CMD directory loop checking. 

> OBD_PING

Export keepalive from client. 

> OBD_LOG_CANCEL

Complete distributed transaction. 

> LDLM_ENQUEUE  

Enqueue a new lock. 

> LDLM_CONVERT   

Convert existing lock type (unused) 

> LDLM_CANCEL  

Cancel lock. 

> LDLM_BL_CALLBACK 
> LDLM_CP_CALLBACK  

Callback from server to client to cancel existing lock or grant pending lock. 

> LDLM_GL_CALLBACK

Trylock or return lock state to caller (for  ls -l). 

Cheers, Andreasw
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101114/62ea2e3f/attachment.htm>
