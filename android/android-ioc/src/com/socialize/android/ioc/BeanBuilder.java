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

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.lang.reflect.WildcardType;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;
import android.content.Context;

/**
 * 
 * @author Jason Polites
 * 
 */
public class BeanBuilder {
	
	private Allocator allocator;

	public BeanBuilder() {
		super();
		this.allocator = new DefaultAllocator();
	}

	@SuppressWarnings("unchecked")
	public <T extends Object> T construct(String className) throws Exception, ClassNotFoundException {
		return (T) construct(className, (Object[]) null);
	}

	@SuppressWarnings("unchecked")
	public <T extends Object> T construct(String className, Object...args) throws Exception,
			ClassNotFoundException {
		return (T) construct((Class<T>) Class.forName(className), args);
	}

	public <T extends Object> T construct(Class<T> clazz) throws Exception {
		return (T) construct(clazz, (Object[]) null);
	}

	public <T extends Object> T construct(Class<T> clazz, Object...args) throws Exception {

		T object = null;

		if(clazz.isAnnotationPresent(Deprecated.class)) {
			Logger.w(clazz.getSimpleName(), "Class [" +
					clazz.getName() +
					"] is deprecated.  It will be created but should be reviewed for continued use");
		}
		
		Constructor<T> matched = getConstructorFor(clazz, args);

		if (matched != null) {
			if(matched.isAnnotationPresent(Deprecated.class)) {
				Logger.w(clazz.getSimpleName(), "Constructor [" +
						matched.toGenericString() +
						"] used for class [" +
						clazz.getName() +
						"] is deprecated.  It will be used but should be reviewed for continued use");
			}
			
			if(allocator != null) {
				object = allocator.allocate(matched, args);
			}
			else {
				object = matched.newInstance(args);
			}
		}
		else {
			// No constructor found.
			StringBuilder builder = new StringBuilder();
			builder.append("No valid constructor found for class [");
			builder.append( clazz.getName() );
			builder.append( "] with args [" );
			
			if(args != null) {
				int index = 0;
				for (Object arg : args) {
					
					if(index > 0) {
						builder.append(",");
					}
					
					if(arg != null) {
						String name = arg.getClass().getSimpleName();
						
						if(name == null || name.trim().length() == 0) {
							name = arg.getClass().getName();
						}
						
						builder.append(name);
					}
					else {
						builder.append("null");
					}
			
					index++;
				}
			}
			else {
				builder.append( "null" );
			}
			
			builder.append( "]" );
			
			Logger.w(getClass().getSimpleName(), builder.toString());
		}

		return object;
	}

	public Object coerce(Argument value) {

		Object coerced = null;

		if (value.getValue() != null) {
			switch (value.getType()) {

			case BOOLEAN:
				coerced = Boolean.valueOf(value.getValue());
				break;

			case BYTE:
				coerced = Byte.valueOf(value.getValue());
				break;
				
			case FLOAT:
				coerced = Float.valueOf(value.getValue());
				break;

			case DOUBLE:
				coerced = Double.valueOf(value.getValue());
				break;

			case CHAR:
				coerced = Character.valueOf(value.getValue().toString().toCharArray()[0]);
				break;

			case INTEGER:
				coerced = Integer.valueOf(value.getValue());
				break;

			case LONG:
				coerced = Long.valueOf(value.getValue());
				break;

			case SHORT:
				coerced = Short.valueOf(value.getValue());
				break;

			case STRING:
				coerced = value.getValue();
				break;

			default:
				throw new IllegalArgumentException("Cannot coerce a value of type " + value.getType().name());

			}
		}

		return coerced;
	}

	public void setProperty(BeanRef ref, Object instance, String name, Object value) throws IllegalArgumentException, IllegalAccessException, InvocationTargetException {

		Class<?> cls = instance.getClass();

		String setterName = "set" + name.substring(0, 1).toUpperCase() + name.substring(1, name.length());

		Method[] methods = cls.getMethods();
		
		boolean methodMatched = false;

		for (Method method : methods) {

			if (method.getName().equals(setterName)) {
				Class<?>[] paramTypes = method.getParameterTypes();
				Type[] types = method.getGenericParameterTypes();
				if (types != null && types.length == 1) {
					if(isMethodMatched(paramTypes, types, value)) {
						method.invoke(instance, value);
						methodMatched = true;
						break;
					}
				}
			}
		}
		
		if(!methodMatched) {
			// Try setting the field directly
			Field field = findField(cls, name);
			
			if(field != null) {
				field.setAccessible(true);
				
				try {
					field.set(instance, value);
				}
				catch (Exception e) {
					Logger.w(getClass().getSimpleName(), "Failed to set property [" +
							name +
							"] of bean [" +
							cls.getName() +
							"] with value of type [" +
							((value == null) ? "null" : value.getClass().getName()) +
							"]", e);
				}
			}
			else {
				// No method found.
				StringBuilder builder = new StringBuilder();
				builder.append("No public method found called [");
				builder.append(setterName);
				builder.append("] or field called [");
				builder.append( name );
				builder.append("] of class [");
				builder.append( cls.getName() );
				builder.append( "] with args [" );
				builder.append( value.getClass().getName() );
				builder.append( "] when setting properties on bean [");
				builder.append( ref.getName() );
				builder.append("]");
				
				Logger.w(getClass().getSimpleName(), builder.toString());
			}
		}
	}
	
	protected Field findField(Class<?> cls, String name) {
		try {
			return cls.getDeclaredField(name);
		}
		catch (NoSuchFieldException e) {
			cls = cls.getSuperclass();
			
			if(cls != null) {
				return findField(cls, name);
			}
			
			return null;
		}
	}

	@SuppressWarnings("unchecked")
	public <T> Constructor<T> getConstructorFor(Class<T> clazz, Object...args) throws SecurityException {
		Constructor<T>[] constructors = (Constructor<T>[]) clazz.getConstructors();
		
		List<Constructor<T>> compatibleConstructors = new ArrayList<Constructor<T>>(3);
		
		for (Constructor<T> constructor : constructors) {
			Class<?>[] params = constructor.getParameterTypes();
			Type[] types = constructor.getGenericParameterTypes();
			if(isMethodMatched(params,types, args)) {
				compatibleConstructors.add(constructor);
			}
		}

		if (compatibleConstructors.size() > 0) {
			
			if(compatibleConstructors.size() > 1) {
				// We have more than one possible match.
				Constructor<T> match = null;
				for (Constructor<T> constructor : compatibleConstructors) {
					Class<?>[] params = constructor.getParameterTypes();
					Type[] types = constructor.getGenericParameterTypes();
					// Do strict match
					if(isMethodMatched(params,types, true, args)) {
						match = constructor;
						break;
					}
				}
				
				if(match == null) {
					match = compatibleConstructors.get(0);
				}
				
				return match;
			}
			else {
				return compatibleConstructors.get(0);
			}
		}

		return null;
	}

	public Method getMethodFor(Class<?> clazz, String name, Object...args) {
		Method[] methods = clazz.getMethods();
		for (Method method : methods) {
			if (method.getName().equals(name)) {
				Class<?>[] params = method.getParameterTypes();
				Type[] types = method.getGenericParameterTypes();
				if(isMethodMatched(params, types, args)) {
					return method;
				}
			}
		}
		return null;
	}
	
	private boolean isMethodMatched(Class<?>[] params, Type[] genericParams, Object...args) {
		return isMethodMatched(params, genericParams, false, args);
	}
	
	private boolean isMethodMatched(Class<?>[] params, Type[] genericParams, boolean strict, Object...args) {
		
		if (params != null && args != null && params.length == args.length) {
			boolean match = true;
			for (int i = 0; i < params.length; ++i) {
				
				Object arg = args[i];
				
				if (arg == null) {
					arg = Void.TYPE;
				}
				
				if(List.class.isAssignableFrom(params[i])) {
					match &= isListMatch(genericParams, i, arg, strict);
				}
				else if(Set.class.isAssignableFrom(params[i])) {
					match &= isSetMatch(genericParams, i, arg, strict);
				}
				else if(Map.class.isAssignableFrom(params[i])) {
					match &= isMapMatch(genericParams, i, arg, strict);
				}
				else {
					boolean assignable = false;
					
					if(strict) {
						assignable = params[i].equals(arg.getClass());
					}
					else {
						assignable = params[i].isAssignableFrom(arg.getClass());
					}
					
					if (!assignable) {
						if (params[i].isPrimitive()) {
							match &= isUnboxableToPrimitive(params[i], arg, strict);
						}
						else {
							match = false;
						}
					}
					else {
						match &= true;
					}
				}
				
				if(!match) break;
			}
			
			return match;
		}
		else if ((params == null || params.length == 0) && (args == null || args.length == 0)) {
			return true;
		}
		
		return false;
	}
	
	private boolean isListMatch(Type[] genericParams, int index, Object arg, boolean strict) {
		if(List.class.isAssignableFrom(arg.getClass())) {
			return isCollectionMatch(genericParams, index, arg, strict);
		}
		return false;
	}
	
	private boolean isCollectionMatch(Type[] genericParams, int index, Object arg, boolean strict) {
		Collection<?> asColl = (Collection<?>) arg;
		
		if(asColl.size() > 0) {
			
			Type type = genericParams[index];
			
			if(type instanceof ParameterizedType) {
				ParameterizedType parType = (ParameterizedType) type;
				
				Class<?> actualClass = getGenericParameterClass(parType);
				Class<?> componentType = asColl.iterator().next().getClass();

				if(strict) {
					return actualClass.equals(componentType);
				}
				else {
					return actualClass.isAssignableFrom(componentType);
				}
			}
			else {
				// Assume we're ok
				return true;
			}
		}
		else {
			return true;
		}
	}
	
	private boolean isSetMatch(Type[] genericParams, int index, Object arg, boolean strict) {
		
		if(Set.class.isAssignableFrom(arg.getClass())) {
			return isCollectionMatch(genericParams, index, arg, strict);
//			Set<?> asColl = (Set<?>) arg;
//
//			if(asColl.size() > 0) {
//				
//				Type type = genericParams[index];
//				
//				if(type instanceof ParameterizedType) {
//					ParameterizedType parType = (ParameterizedType) genericParams[index];
//					
//					Type actualType = parType.getActualTypeArguments()[0];
//					Class<?> componentType = asColl.iterator().next().getClass();
//					
//					Class<?> actualClass = getTypeClass(actualType);
//
//					if(strict) {
//						return actualClass.equals(componentType);
//					}
//					else {
//						return actualClass.isAssignableFrom(componentType);
//					}
//				}
//				else{
//					// Assume we're ok
//					return true;
//				}
//			}
//			else {
//				return true;
//			}
		}
		
		return false;
	}
	
	private boolean isMapMatch(Type[] genericParams, int index, Object arg, boolean strict) {
		
		if(Map.class.isAssignableFrom(arg.getClass())) {
			Map<?,?> asMap = (Map<?,?>) arg;
			
			if(asMap.size() > 0) {
				Type type = genericParams[index];
				
				if(type instanceof ParameterizedType) {
					ParameterizedType parType = (ParameterizedType) genericParams[index];
					
					Type keyType = parType.getActualTypeArguments()[0];
					Type valType = parType.getActualTypeArguments()[1];
					
					Class<?> keyClass = getTypeClass(keyType);
					Class<?> valClass = getTypeClass(valType);
					
					Object key = asMap.keySet().iterator().next();
					Object value = asMap.get(key);
					
					if(keyClass != null && valClass != null) {
						
						if(strict) {
							return (keyClass.equals(key.getClass()) && valClass.equals(value.getClass()));
						}
						else {
							return (keyClass.isAssignableFrom(key.getClass()) && valClass.isAssignableFrom(value.getClass()));
						}
					}
					else {
						return (keyType.equals(key.getClass()) && valType.equals(value.getClass())) ;
					}
				}
				else {
					// Assume we're ok
					return true;
				}
			}
			else {
				return true;
			}
		}
		
		return false;
		

	}
	
	private Class<?> getTypeClass(Type type) {
		if(type instanceof Class) {
			return (Class<?>) type;
		}
		else if(type instanceof ParameterizedType) {
			ParameterizedType pType = (ParameterizedType) type;
			
			Type owner = pType.getOwnerType();
			
			if(owner != null) {
				return getTypeClass(owner);
			}
			else {
				return getTypeClass(pType.getRawType());
			}
		}
		else if(type instanceof WildcardType) {
			// Use upper bound
			WildcardType wType = (WildcardType) type;
			
			Type[] upperBounds = wType.getUpperBounds();
			
			for (Type bound : upperBounds) {
				Class<?> cls = getTypeClass(bound);
				if(cls != null) {
					return cls;
				}
			}
		}
		return null;
	}
	
	private Class<?> getGenericParameterClass(Type type) {
		return getGenericParameterClass(type, 1);
	}
	
	private Class<?> getGenericParameterClass(Type type, int depth) {
		return getGenericParameterClass(type, depth, 0);
	}
	
	private Class<?> getGenericParameterClass(Type type, int targetDepth, int currentDepth) {
		if(type instanceof Class) {
			return (Class<?>) type;
		}
		else if(type instanceof ParameterizedType) {
			if(currentDepth < targetDepth) {
				return getGenericParameterClass(((ParameterizedType)type).getActualTypeArguments()[0], targetDepth, ++currentDepth);
			}
			else {
				return getTypeClass(type);
			}
		}
		else if(type instanceof WildcardType) {
			// Use upper bound
			WildcardType wType = (WildcardType) type;
			
			Type[] upperBounds = wType.getUpperBounds();
			
			if(currentDepth < targetDepth) {
				currentDepth++;
				for (Type bound : upperBounds) {
					Class<?> cls = getGenericParameterClass(bound, targetDepth, currentDepth);
					if(cls != null) {
						return cls;
					}
				}
			}
			else {
				for (Type bound : upperBounds) {
					Class<?> cls = getTypeClass(bound);
					if(cls != null) {
						return cls;
					}
				}
			}
		}
		return null;
	}
	
	private boolean isUnboxableToPrimitive(Class<?> clazz, Object arg, boolean strict) {
		if (!clazz.isPrimitive()) {
			throw new IllegalArgumentException("Internal Error - The class to test against is not a primitive");
		}
		Class<?> unboxedType = null;
		if (arg.getClass().equals(Integer.class)) {
			unboxedType = Integer.TYPE;
		}
		else if (arg.getClass().equals(Long.class)) {
			unboxedType = Long.TYPE;
		}
		else if (arg.getClass().equals(Byte.class)) {
			unboxedType = Byte.TYPE;
		}
		else if (arg.getClass().equals(Short.class)) {
			unboxedType = Short.TYPE;
		}
		else if (arg.getClass().equals(Character.class)) {
			unboxedType = Character.TYPE;
		}
		else if (arg.getClass().equals(Float.class)) {
			unboxedType = Float.TYPE;
		}
		else if (arg.getClass().equals(Double.class)) {
			unboxedType = Double.TYPE;
		}
		else if (arg.getClass().equals(Boolean.class)) {
			unboxedType = Boolean.TYPE;
		}
		else {
			return false;
		}

		if(strict) {
			return clazz.equals(unboxedType);
		}
		else {
			return isAssignable(clazz, unboxedType);
		}
	}

	private boolean isAssignable(Class<?> to, Class<?> from) {
		if (to == Byte.TYPE) {
			return from == Byte.TYPE;
		}
		else if (to == Short.TYPE) {
			return from == Byte.TYPE || from == Short.TYPE || from == Character.TYPE;
		}
		else if (to == Integer.TYPE || to == Character.TYPE) {
			return from == Byte.TYPE || from == Short.TYPE || from == Integer.TYPE || from == Character.TYPE;
		}
		else if (to == Long.TYPE) {
			return from == Byte.TYPE || from == Short.TYPE || from == Integer.TYPE || from == Long.TYPE || from == Character.TYPE;
		}
		else if (to == Float.TYPE) {
			return from == Byte.TYPE || from == Short.TYPE || from == Integer.TYPE || from == Character.TYPE || from == Float.TYPE;
		}
		else if (to == Double.TYPE) {
			return from == Byte.TYPE || from == Short.TYPE || from == Integer.TYPE || from == Long.TYPE || from == Character.TYPE || from == Float.TYPE || from == Double.TYPE;
		}
		else if (to == Boolean.TYPE) {
			return from == Boolean.TYPE;
		}
		else {
			return to.isAssignableFrom(from);
		}
	}
}
