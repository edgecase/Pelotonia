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
package com.socialize.android.ioc;

import android.content.Context;

import java.io.InputStream;

/**
 * 
 * @author Jason Polites
 *
 */
public interface IOCContainer {

	/**
	 * Gets the bean denoted by the given name (id).  
	 * If this bean is defined as non-singleton, it will be instantiated in this call.
	 * @param <T>
	 * @param name The name of the bean.
	 * @return The bean.
	 */
	public <T> T getBean(String name);
	
	/**
	 * Gets the bean denoted by the given name (id).  
	 * If this bean is defined as non-singleton, it will be instantiated in this call using
	 * the arguments passed as constructor arguments.
	 * @param <T>
	 * @param name The name of the bean.
	 * @param args Optional constructor arguments.  If the bean is defined with fixed constructor arguments, 
	 * the arguments provided here will be appended to the set of arguments used when instantiating the bean.
	 * Only applies to non-singleton beans!
	 * @return The bean.
	 */
	public <T> T getBean(String name, Object...args);
	
	/**
	 * Gets the bean denoted by the given name (id).  
	 * If this bean is defined as non-singleton, it will be instantiated in this call.
	 * @param <T>
	 * @param name The name of the bean.
	 * @param listener A listener called after the bean was created/retrieved.
	 */
	public <T> void getBeanAsync(String name, BeanCreationListener<T> listener);
	
	/**
	 * If this bean is defined as non-singleton, it will be instantiated in this call using
	 * the arguments passed as constructor arguments.
	 * @param <T>
	 * @param name The name of the bean.
	 * @param listener A listener called after the bean was created/retrieved.
	 * @param args Optional constructor arguments.  If the bean is defined with fixed constructor arguments, 
	 * the arguments provided here will be appended to the set of arguments used when instantiating the bean.
	 * Only applies to non-singleton beans!
	 */
	public <T> void getBeanAsync(String name, BeanCreationListener<T> listener, Object...args);
	
	/**
	 * Returns the proxy for the given bean.  A &lt;proxy&lt; element must exist in the bean configuration.
	 * will return the proxy.
	 * @param name The name of the bean.
	 * @return A proxy with the same type as the original bean, but where all method calls can be delegated.  
	 * By default methods are delegated to the original bean.
	 */
	public <T> ProxyObject<T> getProxy(String name);
	
	/**
	 * Returns the proxy for the given bean.  A &lt;proxy&lt; element must exist in the bean configuration.
	 * @param name The name of the bean.
	 * @param args The args that would be sent to the normal getBean(...) call.
	 * @return A proxy with the same type as the original bean, but where all method calls can be delegated.  
	 * By default methods are delegated to the original bean.
	 */
	public <T> ProxyObject<T> getProxy(String name, Object...args);
	
	/**
	 * Sets a proxy object for the bean of the given type.
	 * NOTE: This will NOT work for singleton beans which must be defined with a &lt;proxy&gt; element in the bean config XML.
	 * @param name
	 * @param proxy
	 */
	public void setRuntimeProxy(String name, Object proxy);

	/**
	 * Destroys the container and calls the destroy method of any beans with such a method defined.
	 */
	public void destroy();

	/**
	 * Initializes the container.
	 * @param context The current context.
	 * @param builder
	 * @param in
	 * @throws Exception
	 */
	public void init(Context context, ContainerBuilder builder, InputStream...in) throws Exception;

	/**
	 * Initializes the container.
	 * @param context The current context.
	 * @param in
	 * @throws Exception
	 */
	public void init(Context context, InputStream...in) throws Exception;
	
	/**
	 * Initializes the container.
	 * @param context The current context.
	 * @param builder
	 * @param source
	 * @throws Exception
	 */
	public void init(Context context, ContainerBuilder builder, BeanMappingSource source) throws Exception;

	/**
	 * Initializes the container.
	 * @param context The current context.
	 * @param source
	 * @throws Exception
	 */
	public void init(Context context, BeanMappingSource source) throws Exception;
	
	/**
	 * Returns the number of beans in the container.
	 * @return
	 */
	public int size();
	
	/**
	 * Allows for re-setting of context.
	 * @param context
	 */
	public void setContext(Context context);
	
	/**
	 * Gets the current context registered in the container.
	 * @return
	 */
	public Context getContext();
	
	/**
	 * Called when the current context is destroyed (Activity onDestroy)
	 * @param context
	 */
	public void onContextDestroyed(Context context);

}
