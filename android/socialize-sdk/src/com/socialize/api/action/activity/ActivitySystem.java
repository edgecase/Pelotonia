/*
 * Copyright (c) 2012 Socialize Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.socialize.api.action.activity;

import com.socialize.api.SocializeSession;
import com.socialize.api.action.ActionType;
import com.socialize.entity.SocializeAction;
import com.socialize.error.SocializeException;
import com.socialize.listener.activity.ActionListener;


/**
 * @author Jason Polites
 */
public interface ActivitySystem {

	public static final String USER_ENDPOINT = "/user/";
	public static final String ACTIVITY_ENDPOINT = "/activity/";
	
	/**
	 * Gets a socialize action.  This call is SYNCHRONOUS!
	 * @param session
	 * @param id
	 * @param type
	 * @throws SocializeException
	 * @return
	 */
	public SocializeAction getAction(SocializeSession session, long id, ActionType type) throws SocializeException;	
	
	public void getActivityByUser(SocializeSession session, long id, ActionListener listener);
	
	public void getActivityByUser(SocializeSession session, long id, int startIndex, int endIndex, ActionListener listener);
	
	public void getActivityByApplication(SocializeSession session, int startIndex, int endIndex, ActionListener listener);
	
	public void getActivityByEntity(SocializeSession session, String entityKey, int startIndex, int endIndex, ActionListener listener);
	
	public void getActivityByUserAndEntity(SocializeSession session, long userId, String entityKey, int startIndex, int endIndex, ActionListener listener);

}